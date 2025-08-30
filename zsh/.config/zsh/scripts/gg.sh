#!/usr/bin/env bash

debug() {
    [[ "${GG_DEBUG}" == "1" ]] && echo "[DEBUG:${funcfiletrace[1]##*:}] $*" >&2
}

branch_to_dirname() {
    echo "$1" | sed 's/\//-/g'
}

dirname_to_branch() {
    echo "$1"
}

get_wt_original_branch() {
    local wt_path="$1"
    basename "$wt_path" | awk -F'.wt.' '{if (NF==2) gsub("-", "/", $2); print $2}'
}

gg() {
    if ! command git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "fatal: not a git repository (or any of the parent directories): .git"
        return 1
    fi

    main_root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")"
    here_root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
    current_branch="$(command git branch --show-current)"

    debug "Main root dir: $main_root"
    debug "Here root dir: $here_root"
    debug "Current branch: $current_branch"

    case $1 in
    create)
        case $2 in
        branch)
            command git branch "$3"
            return 0
            ;;
        wt)
            if [[ $3 =~ ^(main|master)$ ]]; then
                echo "Error: Branch '$3' cannot have a worktree"
                return 1
            fi

            # Check if branch is already checked out somewhere
            local checkout_location=$(command git worktree list --porcelain -z | awk -v RS='\0' -v b="refs/heads/$3" '
                $1=="worktree"{p=$2}
                $1=="branch" && $2==b{print p; exit}
            ')

            if [[ -n "$checkout_location" && "$checkout_location" != "$main_root" ]]; then
                echo "Error: Branch '$3' is already checked out at '$checkout_location'"
                return 1
            fi

            # Convert branch name to dir name
            local safe_branch=$(branch_to_dirname "$3")
            branch_dir="$(dirname "$main_root")/$(basename "$main_root").wt.$safe_branch"
            debug "Branch dir: $branch_dir"

            if [[ "$checkout_location" == "$main_root" ]]; then
                debug "Branch '$3' is checked out in main root, switching main to master/main"
                pushd "$main_root" >/dev/null
                command git checkout main 2>/dev/null || command git checkout master 2>/dev/null
                popd >/dev/null
            fi

            output=$(command git worktree add -b "$3" "$branch_dir" 2>&1)
            debug "Output: $output"

            if [[ $output == *"cannot lock ref"* || $output == *"cannot create"* ]]; then
                echo "Error: $output"
                return 1
            fi

            if [[ $output == *"a branch named '$3' already exists"* ]]; then
                debug "Creating worktree for existing branch '$3' in '$branch_dir'"
                output=$(command git worktree add "$branch_dir" "$3" 2>&1)
                if [[ $? -eq 0 ]]; then
                    cd "$branch_dir" || return 1
                else
                    echo "Error: $output"
                    return 1
                fi
            else
                debug "Created worktree for branch '$3' in '$branch_dir'"
                cd "$branch_dir" || return 1
            fi
            return 0
            ;;
        esac
        ;;

    delete | del | remove | rm)
        case $2 in
        branch)
            if [[ $3 =~ ^(main|master)$ ]]; then
                echo "Error: Branch '$3' cannot be deleted"
                return 1
            fi

            echo "Delete branch '$3'? (y/n)"
            read -r answer
            case $answer in
            y | Y)
                if command git branch -D "$3"; then
                    echo "Branch '$3' deleted"
                    return 0
                else
                    return 1
                fi
                ;;
            n | N)
                echo "Branch '$3' not deleted"
                return 0
                ;;
            *)
                echo "Invalid input, branch '$3' not deleted"
                return 1
                ;;
            esac
            ;;

        wt)
            if [[ $3 =~ ^(main|master)$ ]]; then
                echo "Error: Branch '$3' cannot have a worktree"
                return 1
            fi

            # Find worktree by dir name
            local safe_branch=$(branch_to_dirname "$3")
            local expected_wt_dir="$(dirname "$main_root")/$(basename "$main_root").wt.$safe_branch"

            # Check if this worktree exists
            wt_path="$(
                command git worktree list --porcelain -z | awk -v RS='\0' -v p="$expected_wt_dir" '
        $1=="worktree" && $2==p {print $2; exit}
        '
            )"

            if [[ -z "$wt_path" ]]; then
                echo "Error: No worktree found for branch '$3'"
                return 1
            fi

            # Move to main dir before deleting current dir
            if [[ "$here_root" == "$wt_path" ]]; then
                echo "Currently in worktree to be deleted. Moving to main root first..."
                cd "$main_root" || return 1
            fi

            echo "Delete worktree '$3' in '$wt_path'? (y/n)"
            read -r answer
            case $answer in
            y | Y)
                if command git worktree remove "$wt_path"; then
                    echo "Worktree '$3' deleted"

                    echo "Also delete branch '$3'? (y/n)"
                    read -r delete_branch
                    case $delete_branch in
                    y | Y)
                        if command git branch -D "$3"; then
                            echo "Branch '$3' deleted"
                        else
                            echo "Failed to delete branch '$3'"
                        fi
                        ;;
                    n | N)
                        echo "Branch '$3' kept"
                        ;;
                    *)
                        echo "Invalid input, branch '$3' kept"
                        ;;
                    esac
                    return 0
                else
                    return 1
                fi
                ;;
            n | N)
                echo "Worktree '$3' not deleted"
                return 0
                ;;
            *)
                echo "Invalid input, worktree '$3' not deleted"
                return 1
                ;;
            esac
            ;;
        esac
        ;;
    merge)
        if [[ "$3" != "into" || -z "$4" ]]; then
            echo "Usage: gg merge <source> into <target>"
            echo "Example: gg merge feature/rsi into main"
            return 1
        fi

        local source="$2"
        local target="$4"

        # Validate branches
        if ! git show-ref --quiet --verify "refs/heads/$source"; then
            echo "Error: Source branch '$source' does not exist"
            return 1
        fi
        if ! git show-ref --quiet --verify "refs/heads/$target"; then
            echo "Error: Target branch '$target' does not exist"
            return 1
        fi

        local return_path="$PWD"

        echo "Switching to '$target' for merge..."
        gg "$target" || return 1

        echo "Merging '$source' into '$target'..."
        if command git merge "$source" --no-edit; then
            echo "Successfully merged '$source' into '$target'"
            cd "$return_path"
        else
            echo "Merge conflict - resolve conflicts and commit"
            echo "You are now on branch '$target'"
            return 1
        fi
        ;;
    sync)
        local branch="${2:-$current_branch}"

        if [[ -z "$branch" ]]; then
            echo "Error: No branch specified and not on any branch"
            return 1
        fi

        echo "Fetching latest for '$branch'..."
        command git fetch origin "$branch" || return 1

        # Check if branch exists locally
        if ! git show-ref --quiet --verify "refs/heads/$branch"; then
            echo "Creating local branch '$branch' from 'origin/$branch'"
            command git branch "$branch" "origin/$branch"
        fi

        local return_needed=false
        local return_path="$PWD"

        if [[ "$current_branch" != "$branch" ]]; then
            echo "Switching to '$branch' for sync..."
            gg "$branch" || return 1
            return_needed=true
        fi

        # sync
        echo "Syncing '$branch' with 'origin/$branch'..."
        if command git merge "origin/$branch" --ff-only 2>/dev/null; then
            echo "Fast-forwarded '$branch'"
        elif command git merge "origin/$branch" --no-edit; then
            echo "Merged 'origin/$branch' into '$branch'"
        else
            echo "Sync failed - resolve conflicts and commit"
            return 1
        fi

        # Return to orig loc if needed
        if [[ "$return_needed" == true ]]; then
            cd "$return_path"
            gg "$current_branch" >/dev/null 2>&1
        fi
        ;;
    help | --help | -h)
        cat <<'EOF'
gg - Git worktree manager

USAGE:
  gg <branch>                    Switch to branch
  gg create branch <name>        Create new branch
  gg create wt <name>            Create worktree for branch
  gg delete branch <name>        Delete branch (del, rm, remove)
  gg delete wt <name>            Delete worktree (del, rm, remove)
  gg merge <src> into <target>   Merge source branch into target
  gg sync [branch]               Sync branch with origin (current if omitted)
  gg help                        Show this help (--help, -h)

EXAMPLES:
  gg feature/login              # Switch to feature/login branch
  gg create wt bugfix/auth      # Create worktree for bugfix/auth
  gg create branch refactor/db  # Create new branch
  gg merge feature/login into develop
  gg sync                       # Sync current branch with origin
  gg rm wt feature/old          # Remove completed feature worktree
EOF
        return 0
        ;;

    *)
        if ! git show-ref --quiet --verify "refs/heads/$1"; then
            echo "Error: Branch '$1' does not exist"
            return 1
        fi

        local branch="$1"

        # Find worktree for this branch by checking git worktree list
        wt_path="$(
            command git worktree list --porcelain -z | awk -v RS='\0' -v b="refs/heads/$branch" '
                $1=="worktree"{p=$2}
                $1=="branch" && $2==b{print p}
            '
        )"

        # Exclude main root from worktree path
        if [[ "$wt_path" == "$main_root" ]]; then
            wt_path=""
        fi

        # Find where branch is checked out
        local branch_location=$(command git worktree list --porcelain -z | awk -v RS='\0' -v b="refs/heads/$branch" '
            $1=="worktree"{p=$2}
            $1=="branch" && $2==b{print p; exit}
        ')

        # If in work tree, restore its original branch
        if [[ "$here_root" != "$main_root" ]]; then
            local original_branch=$(get_wt_original_branch "$here_root")
            debug "In worktree, original branch: $original_branch, current: $current_branch"

            if [[ -n "$original_branch" && "$current_branch" != "$original_branch" ]]; then
                debug "Restoring worktree at $here_root to branch '$original_branch'"
                command git checkout "$original_branch" 2>/dev/null
            fi

        # If in main root with free branch, restore main
        elif [[ "$here_root" == "$main_root" && ! "$current_branch" =~ ^(main|master)$ && "$branch" != "$current_branch" ]]; then
            if [[ -n "$wt_path" || "$branch" =~ ^(main|master)$ ]]; then
                debug "Restoring main root to main/master"
                command git checkout main 2>/dev/null || command git checkout master 2>/dev/null
            fi
        fi

        if [[ $branch =~ ^(main|master)$ ]]; then
            debug "Switching to main/master in main root"
            cd "$main_root" || return 1
            command git checkout "$branch" 2>/dev/null

        elif [[ -n "$wt_path" ]]; then
            # Branch has wt, cd there
            debug "Moving to worktree at $wt_path"
            cd "$wt_path" || return 1

            command git checkout "$branch" 2>/dev/null

        elif [[ -n "$branch_location" && "$branch_location" != "$here_root" ]]; then
            # Branch is checked out elsewhere, cd there

            debug "Branch '$branch' is checked out at $branch_location, moving there"
            cd "$branch_location" || return 1

        else
            # if free  branch, check it out in current location
            debug "Switching to free branch '$branch'"
            command git checkout "$branch" 2>&1
        fi
        ;;
    esac
}
