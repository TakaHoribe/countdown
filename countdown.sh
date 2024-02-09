#!/bin/bash

# Function: Convert time expression to seconds
convert_to_seconds() {
    local expression=$1
    local seconds=0

    # Extract numerical value and unit from the expression
    local value=$(echo $expression | sed 's/[^0-9]*//g')
    local unit=$(echo $expression | sed 's/[0-9]*//g')

    # Convert to seconds based on the unit
    case $unit in
        "s")
            seconds=$((value))
            ;;
        "m")
            seconds=$((value * 60))
            ;;
        "h")
            seconds=$((value * 3600))
            ;;
        *)
            echo "Invalid time unit: $unit"
            exit 1
            ;;
    esac

    echo $seconds
}

# Function: Display countdown in HH:MM:SS format
countdown_hms() {
    local time=$1
    while [ $time -ge 0 ]; do
        clear
        formatted_time=$(format_time $time)
        figlet -c -f big $formatted_time
        sleep 1
        ((time--))
    done
}

# Function: Display countdown in seconds
countdown_seconds() {
    local time=$1
    while [ $time -ge 0 ]; do
        clear
        figlet -c -f big $time "s"
        sleep 1
        ((time--))
    done
}

# Function: Display negative countdown
negative_countdown() {
    local time=$1
    countdown_hms $time
    time=1
    while true; do
        clear
        formatted_time=$(format_time $time)
        figlet -c -f big $formatted_time
        sleep 1
        ((time++))
    done
}

# Function: Format seconds into HH:MM:SS
format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(( (seconds % 3600) / 60 ))
    local seconds=$((seconds % 60))

    printf "%02d : %02d : %02d\n" $hours $minutes $seconds
}

# Function: Main processing
main() {
    local time_expression=$1
    local mode=$2
    local display_mode=$3
    local interrupted=false

    # Convert time expression to seconds
    local time_seconds=$(convert_to_seconds $time_expression)

    while true; do
        if [ "$mode" = "-r" ]; then
            negative_countdown $time_seconds
        else 
            if [ "$display_mode" = "-s" ]; then
                countdown_seconds $time_seconds
            else
                countdown_hms $time_seconds
            fi
        fi

        if $interrupted; then
            break
        fi

        if [ "$mode" != "-l" ]; then
            break
        fi
    done
}

# Main processing call
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <time> [-l] [-r] [-s]"
    exit 1
fi

time=$1
loop=$2
display_mode=$3

if [ "$loop" = "-r" ]; then
    echo "countdown starts in reverse mode"
    sleep 1
    main $time "-r" "$display_mode"
elif [ "$loop" = "-l" ]; then
    echo "countdown starts in loop mode"
    sleep 1
    main $time "-l" "$display_mode"
else
    main $time "" "$display_mode"
fi

return 0
