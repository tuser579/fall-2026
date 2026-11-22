# name="Tuser"

# echo "${name}islam"
# echo "$name""islam"


# read -p "Enter numbers: " -a numbers

# echo "${numbers[0]}"
# echo "${numbers[1]}"
# echo "$numbers[*]" wrong way to print all elements of an array
# echo "${numbers[*]}"


# printf "%-15s %s\n" "Name" "Age"
# printf "%-15s %-10d\n" "Rahim" 21
# printf "%-15s %-10d\n" "Karim" 22
# printf "%-15s %-10d\n" "Tuser" 23 


# read -p "Enter first number: " a
# read -p "Enter second number: " b

# echo "Addition: $((a + b))"
# echo "Subtraction: $((a - b))"
# echo "Multiplication: $((a * b))"
# echo "Division: $((a / b))"
# echo "Remainder: $((a % b))"


a=10
b=20

((sum=a+b))

echo "$sum"