#!/bin/bash
#
# Usage: dmenupass_dual_clipboard.sh
#
# See Also: https://git.zx2c4.com/password-store/tree/contrib/dmenu
#
# This script interract with your local password-store filesystem via dmenu.
# It will get both user/email and password from your pass entries.
#
# Rows are matched using regexp.
#
# It uses clipit as clipboard manager so the selected enrty is also in the
# clipboard history.
#
# - push entry to clipboard history
# - copy user/email to SECONDARY
# - copy password to PRIMARY
# - if matched record hold an exec: row, the code is executed and the result
#   pushed to clipboard

# pass our entries files to dmenu
# result stored in PASSWORD_ENTRY
lookup() {
  shopt -s nullglob globstar

  local prefix=${PASSWORD_STORE_DIR-$HOME/.password-store}
  local password_files=( "$prefix"/**/*.gpg )
  password_files=( "${password_files[@]#"$prefix"/}" )
  password_files=( "${password_files[@]%.gpg}" )

  PASSWORD_ENTRY=$(printf '%s\n' "${password_files[@]}" | dmenu "$@")

  if [[ -z $PASSWORD_ENTRY ]] ; then
    # not found
    return 1
  fi
}

main() {
    if lookup
    then
      load_entry_to_clipboard $PASSWORD_ENTRY
    fi
}

load_entry_to_clipboard() {
    local pass_entry="$1"

    # copy entry matched to clipboard
    echo "pass show $pass_entry" | clipit

    # looking for extra data
    local regexp1="user|email"
    local regexp2="^($regexp1|url)"

    # We copy email or user to SECONDARY clipboard (middle mouse button)
    # This grep store matching lines in the file order.
    # We look at the same pattern in the line order.
    # User must reorder line in the crytped storage to match first entry if
    # needed.

    # loop over lines
    local old_ifs=$IFS
    local l
    IFS=$'\n'
    local raw_entry="$(pass show "$pass_entry")"
    # match extra entries
    for l in $(grep -Ei "^($regexp1)" <<< "$raw_entry")
    do
      # GNU sed: 'I': case insensitive, ! not match
      val=$(echo "$l" | sed -n -e "/^#/ ! { s/^[^:]\\+: *//I p; }")
      if [[ ! -z "$val" ]]
      then
        echo -n "$val" | xclip -selection XA_SECONDARY
        break
      fi
    done
    IFS=$old_ifs

    # last action to the clipboard

    # detect oathtool
    local oathtool=$(
        awk 'BEGIN{IGNORECASE = 1;} $1 == "oathtool:" {print $2}' \
        <<< "$raw_entry")
    if [[ -n $oathtool && $oathtool == true ]]
    then
      local auth_code=$(echo "$raw_entry" | head -1)
      local two_factor_code=$(oathtool --totp --base32 "$auth_code")
      if [[ -n $two_factor_code ]]
      then
        echo "$two_factor_code" | clipit
      fi
    else
      # pass will copy pass into clipboard (PRIMARY)
      pass show -c "$pass_entry"
    fi
}

# sourcing code detection, if code is sourced for debug purpose,
# main is not executed.
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if  [[ $sourced -eq 0 ]]
then
    # pass positional argument as is
    main "$@"
fi
