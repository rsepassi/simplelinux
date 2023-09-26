rewrite_flags() {
    transformed_args=""
    for arg in "$@"; do
        case "$arg" in
            -Wp,-MD,*)
                mfarg=$(echo "$arg" | sed 's/^-Wp,-MD,//')
                transformed_args="${transformed_args} -MD -MF ${mfarg}"
                ;;
            -Wp,-MMD,*)
                mfarg=$(echo "$arg" | sed 's/^-Wp,-MMD,//')
                transformed_args="${transformed_args} -MMD -MF ${mfarg}"
                ;;
            -Wl,--warn-common)
                ;;
            -Wl,--verbose)
                ;;
            -Wl,-Map,*)
                ;;
             *)
                transformed_args="${transformed_args} ${arg}"
        esac
    done
    echo "$transformed_args"
}
