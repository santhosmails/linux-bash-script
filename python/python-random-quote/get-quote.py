# Import the random module to use for selecting a random quote
import random

def main():
    # Open the file "quotes.txt" in read mode
    # The 'with' statement ensures the file is properly closed after we're done
    with open("quotes.txt", "r") as f:
        # Read all lines from the file into a list
        quotes = f.readlines()

    # Process the quotes:
    # - strip() removes leading and trailing whitespace from each quote
    # - The condition 'if quote.strip()' filters out empty lines
    # This creates a new list with cleaned quotes and no empty lines
    quotes = [quote.strip() for quote in quotes if quote.strip()]

    # Check if there are any quotes in the list
    if quotes:
        # If quotes exist, select and print a random one
        # random.choice() picks a random element from the list
        print(random.choice(quotes))
    else:
        # If no quotes are found, print an error message
        print("No quotes found in the file.")

# This block ensures that the main() function is only called if this script
# is run directly (not imported as a module)
if __name__ == "__main__":
    main()
