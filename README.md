# SwapEnSolidity
Se generan dos tokens y se intercambian por el método de producto constante.
# SimpleDEX - Contrato de intercambio de Tokens con el método de Producto Constante

## 📋 Descripción

Contrato inteligente que implementa un intercambio de tokens (swap), usando la fórmula del producto constante `x * y = k`.

## 🧮 Fórmula del Producto Constante

```
Inicial
x * y = k
En el siguiente movimiento
(x+dx)*(y-dy)=k=x*y
Luego
dy=y-k/(x+dx)
```

Donde:

- `x` = reserva del Token A
- `y` = reserva del Token B
- `k` = constante que debe mantenerse

### Cálculo de Swap

```
amountOut = (reserveOut * amountIn) / (reserveIn + amountIn)
```

## 🚀 Funcionalidades

### 💧 Gestión de Liquidez

- **`addLiquidity()`** - Agregar liquidez al pool
- **`removeLiquidity()`** - Retirar liquidez (solo owner)
- **`getReserves()`** - Ver reservas actuales

### 🔄 Intercambios (Swaps)

- **`swapAforB()`** - Intercambiar Token A por Token B
- **`swapBforA()`** - Intercambiar Token B por Token A

### 📊 Consultas

- **`getAmountOut()`** - Calcular output para A → B
- **`getAmountOutReverse()`** - Calcular output para B → A
- **`getConstantProduct()`** - Ver valor actual de k
- **`getPrice(address_token)`** - Obtener precio de un token en términos del otro
- **`getPriceAinB()`** - Precio de Token A en términos de Token B
- **`getPriceBinA()`** - Precio de Token B en términos de Token A

## 💡 Ejemplo de Uso

### 1. Agregar Liquidez

```solidity
// Agregar 1000 tokens de cada tipo
swapContract.addLiquidity(1000e18, 1000e18);
```

### 2. Consultar Precio

```solidity
// ¿Cuánto Token B recibo por 100 Token A?
uint256 output = swapContract.getAmountOut(100e18);

// ¿Cuál es el precio actual de Token A en términos de Token B?
uint256 priceA = swapContract.getPrice(address(tokenA));

// Funciones de conveniencia para precios
uint256 priceAinB = swapContract.getPriceAinB(); // A → B
uint256 priceBinA = swapContract.getPriceBinA(); // B → A
```

### 3. Realizar Swap

```solidity
// Intercambiar 100 Token A por Token B
swapContract.swapAforB(100e18);
```

### 4. Consultar Precios en Tiempo Real

```solidity
// Obtener precio actual de Token A
uint256 currentPriceA = swapContract.getPrice(address(tokenA));

// Verificar si el precio es favorable antes del swap
if (currentPriceA >= expectedMinPrice) {
    swapContract.swapAforB(100e18);
}
```

### 💰 Funciones de Precio

El contrato incluye varias funciones para consultar precios:

1. **`getPrice(address _token)`** - Precio universal de cualquier token
2. **`getPriceAinB()`** - Precio específico: Token A → Token B
3. **`getPriceBinA()`** - Precio específico: Token B → Token A

**Ejemplo de precios:**

```solidity
// Con reservas: 1000A / 2000B
uint256 priceA = getPrice(tokenA); // 2.0 (2000/1000)
uint256 priceB = getPrice(tokenB); // 0.5 (1000/2000)
```

## ⚠️ Consideraciones

1. **No incluye fees** - Es una implementación básica
2. **Solo owner puede retirar liquidez** - No hay LP tokens
3. **Aprobaciones requeridas** - Los tokens deben estar aprobados antes del swap

## 🛠️ Tecnologías

- **Solidity ^0.8.22**
- **OpenZeppelin** (ERC20, Ownable)

