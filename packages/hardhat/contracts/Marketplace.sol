// SPDX-License-Identifier: MIT

// Version of Solidity compiler this program was written for
pragma solidity >=0.7.0 <0.9.0;

// Interface for the ERC20 token, in our case cUSD
interface IERC20Token {
    // Transfers tokens from one address to another
    function transfer(address, uint256) external returns (bool);

    // Approves a transfer of tokens from one address to another
    function approve(address, uint256) external returns (bool);

    // Transfers tokens from one address to another, with the permission of the first address
    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    // Returns the total supply of tokens
    function totalSupply() external view returns (uint256);

    // Returns the balance of tokens for a given address
    function balanceOf(address) external view returns (uint256);

    // Returns the amount of tokens that an address is allowed to transfer from another address
    function allowance(address, address) external view returns (uint256);

    // Event for token transfers
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Event for approvals of token transfers
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// Contract for the marketplace
contract Marketplace {
    // Keeps track of the number of products in the marketplace
    uint256 internal productsLength = 0;
    // Address of the cUSDToken
    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    // Structure for a product
    struct Product {
        // Address of the product owner
        address payable owner;
        // Name of the product
        string name;
        // Link to an image of the product
        string image;
        // Description of the product
        string description;
        // Location of the product
        string location;
        // Price of the product in tokens
        uint256 price;
        // Number of times the product has been sold
        uint256 sold;
        // Number of product to be sold
        uint256 supply;
    }

    // Mapping of products to their index
    mapping(uint256 => Product) internal products;

    // Store all the items bought buy a user
    mapping(address => mapping(uint256 => Product)) public userProducts;

    // Writes a new product to the marketplace
    function writeProduct(
        string memory _name,
        string memory _image,
        string memory _description,
        string memory _location,
        uint256 _price,
        uint256 _supply
    ) public {
        // Number of times the product has been sold is initially 0 because it has not been sold yet
        uint256 _sold = 0;
        // Adds a new Product struct to the products mapping
        products[productsLength] = Product(
            // Sender's address is set as the owner
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold,
            _supply
        );
        // Increases the number of products in the marketplace by 1
        productsLength++;
    }

    // Reads a product from the marketplace
    function readProduct(
        // Index of the product
        uint256 _index
    )
        public
        view
        returns (
            // Address of the product owner, payable because the owner can receive tokens
            Product memory
        )
    {
        // Returns the details of the product
        return (products[_index]);
    }

    // Buys a product from the marketplace
    function buyProduct(
        // Index of the product
        uint256 _index
    ) public payable {
        require(products[_index].supply > 0, "Product sold out");
        // Transfers the tokens from the buyer to the seller
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                // Sender's address is the buyer
                msg.sender,
                // Receiver's address is the seller
                products[_index].owner,
                // Amount of tokens to transfer is the price of the product
                products[_index].price
            ),
            // If transfer fails, throw an error message
            "Transfer failed."
        );
        // Increases the number of times the product has been sold
        products[_index].sold++;
        products[_index].supply--;
        userProducts[msg.sender][_index] = products[_index];
    }

    // Buy all available product
    function buyAllProduct(uint256 _index) public payable {
        uint256 totalPrice = products[_index].price * products[_index].supply;
        require(msg.sender != products[_index].owner, "Owner can not buy all his product");
        require(products[_index].supply > 0, "Product sold out");
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                // Sender's address is the buyer
                msg.sender,
                // Receiver's address is the seller
                products[_index].owner,
                // Amount of tokens to transfer is the price of the product
                totalPrice
            ),
            // If transfer fails, throw an error message
            "Transfer failed."
        );

        products[_index].sold = products[_index].supply;
        products[_index].supply -= products[_index].supply;
        userProducts[msg.sender][_index] = products[_index];
    }

    // Returns the number of products in the marketplace
    function getProductsLength() public view returns (uint256) {
        return (productsLength);
    }
}