// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Contrato SimpleDEX
/// @notice Contrato que usa la fórmula del producto constante (x * y = k)
contract SimpleDEX is Ownable {
    IERC20 public tokenA;
    IERC20 public tokenB;

    event TokenSwapped(
        address indexed user,
        string direction,
        uint256 amountIn,
        uint256 amountOut
    );
    event LiquidityAdded(
        address indexed provider,
        uint256 amountTokenA,
        uint256 amountTokenB
    );
    event LiquidityRemoved(
        address indexed to,
        uint256 amountTokenA,
        uint256 amountTokenB
    );

    constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
        require(
            _tokenA != address(0) && _tokenB != address(0),
            "Invalid token address"
        );
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /// @notice Permite agregar liquidez al contrato
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /// @notice Permite al owner retirar liquidez del contrato
    function removeLiquidity(
        uint256 amountA,
        uint256 amountB
    ) external onlyOwner {
        require(
            amountA <= tokenA.balanceOf(address(this)),
            "Not enough TokenA"
        );
        require(
            amountB <= tokenB.balanceOf(address(this)),
            "Not enough TokenB"
        );

        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /// @notice Calcula el producto constante k actual
    function getConstantProduct() external view returns (uint256 k) {
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));
        k = reserveA * reserveB;
    }

    /// @notice Obtiene las reservas actuales de ambos tokens
    function getReserves()
        external
        view
        returns (uint256 reserveA, uint256 reserveB)
    {
        reserveA = tokenA.balanceOf(address(this));
        reserveB = tokenB.balanceOf(address(this));
    }

    /// @notice Obtiene el precio de un token en términos del otro
    function getPrice(address _token) external view returns (uint256 price) {
        require(
            _token == address(tokenA) || _token == address(tokenB),
            "Invalid token address"
        );

        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        if (_token == address(tokenA)) {
            // Precio de tokenA en términos de tokenB
            price = (reserveB * 1e18) / reserveA;
        } else {
            // Precio de tokenB en términos de tokenA
            price = (reserveA * 1e18) / reserveB;
        }
    }

    /// @notice Obtiene el precio de tokenA en términos de tokenB
    function getPriceAinB() external view returns (uint256 priceAinB) {
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        priceAinB = (reserveB * 1e18) / reserveA;
    }

    /// @notice Obtiene el precio de tokenB en términos de tokenA
    function getPriceBinA() external view returns (uint256 priceBinA) {
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        priceBinA = (reserveA * 1e18) / reserveB;
    }

    /// @notice Calcula cuánto tokenB se recibirá al enviar una cantidad de tokenA
    function getAmountOut(
        uint256 amountAIn
    ) external view returns (uint256 amountBOut) {
        require(amountAIn > 0, "Amount must be > 0");

        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        // Fórmula del producto constante
        amountBOut = (reserveB * amountAIn) / (reserveA + amountAIn);
    }

    /// @notice Calcula cuánto tokenA se recibirá al enviar una cantidad de tokenB
    function getAmountOutReverse(
        uint256 amountBIn
    ) external view returns (uint256 amountAOut) {
        require(amountBIn > 0, "Amount must be > 0");

        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        // Fórmula del producto constante
        amountAOut = (reserveA * amountBIn) / (reserveB + amountBIn);
    }

    /// @notice Intercambia TokenA por TokenB usando fórmula de producto constante
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Amount must be > 0");

        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        // Calcular cuánto tokenB dar usando la fórmula del producto constante
        uint256 amountBOut = (reserveB * amountAIn) / (reserveA + amountAIn);

        require(amountBOut > 0, "Insufficient output amount");
        require(reserveB > amountBOut, "Insufficient TokenB liquidity");

        // Transferir tokens
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        emit TokenSwapped(msg.sender, "AtoB", amountAIn, amountBOut);
    }

    /// @notice Intercambia TokenB por TokenA usando fórmula de producto constante
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Amount must be > 0");

        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));

        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        // Calcular cuánto tokenA dar usando la fórmula del producto constante
        uint256 amountAOut = (reserveA * amountBIn) / (reserveB + amountBIn);

        require(amountAOut > 0, "Insufficient output amount");
        require(reserveA > amountAOut, "Insufficient TokenA liquidity");

        // Transferir tokens
        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        emit TokenSwapped(msg.sender, "BtoA", amountBIn, amountAOut);
    }
}
