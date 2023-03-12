// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./interfaces/ITTSwapV1Shop.sol";
import "./interfaces/Marketor/IMarketorV1State.sol";

import "./libraries/LLowGasSafeMath.sol";
import "./libraries/LSafeCast.sol";
import "./libraries/LUnit.sol";
import "./libraries/LUnitBitmap.sol";
import "./libraries/LProof.sol";
import "./libraries/LPriceLog.sol";
import "./libraries/base/LShop.sol";
import "./libraries/TransferHelper.sol";
import "./libraries/LSwapMath.sol";

import "./TTSwapV1Market.sol";
import "./TTSwapV1Customer.sol";
import "./TTSwapV1ShopCreate.sol";
import "./interfaces/IERC20Minimal.sol";

import "./NoDelegateCall.sol";

contract TTSwapV1Shop is ITTSwapV1Shop, NoDelegateCall {
    using LLowGasSafeMath for uint256;
    using LLowGasSafeMath for int256;
    using LSafeCast for uint256;
    using LSafeCast for int256;
    using LUnit for mapping(int24 => LUnit.Info);
    using LUnitBitmap for mapping(int16 => uint256);
    using LProof for mapping(bytes32 => LProof.Info);
    using LProof for LProof.Info;
    using LPriceLog for LPriceLog.PriceLog[65535];

    address public immutable override market;
    address public immutable override coin;
    address public immutable override thing;
    uint24 public immutable override profit;
    int24 public override unitSpacing;
    uint128 public override maxInvestionPerUnit;
    LProfitShares.Info public profitshares;
    //思考,关于门店的创建者
    address public gater;
    uint8 public scope;
    bool public marketlock;
    bool public gatelock;

    //记录各自手续费的情况(门户,社区,推荐者,用户返佣)
    mapping(address => ProtocalProfits) public shopfee;

    struct State0 {
        uint160 sqrtPriceX96;
        int24 unit;
        uint16 lookerIndex;
        uint16 lookerCardinality;
        uint16 lookerCardinalityNext;
        uint8 profitProtocol;
        bool unlocked;
    }

    State0 public override state0;

    //总费用
    uint256 public override profitGrowthGlobalCoinX128;
    //  uint256 public override profitGrowthGlobalThingX128;

    //协议费
    struct ProtocalProfits {
        uint128 coin;
        uint128 thing;
    }

    ProtocalProfits public override protocolProfits;

    uint128 public override investion;

    mapping(int24 => LUnit.Info) public override units;

    mapping(int16 => uint256) public override unitBitmap;

    mapping(bytes32 => LProof.Info) public override proofs;

    LPriceLog.PriceLog[65535] public override priceLogers;

    constructor() {
        (
            market,
            coin,
            thing,
            profit,
            unitSpacing,
            profitshares
        ) = TTSwapV1ShopCreate(msg.sender).inputParas();
        marketlock = false;
        gatelock = false;
        maxInvestionPerUnit = LUnit.unitSpacingToMaxinvestionPerUnit(
            unitSpacing
        );
    }

    modifier isopen() {
        require(state0.unlocked, "OPen");
        _;
    }

    modifier lock() {
        require(state0.unlocked, "LOK");
        state0.unlocked = false;
        _;
        state0.unlocked = true;
    }
    modifier onlyMarketManager() {
        require(IMarketorV1State(market).isValidMarketor() == true);
        _;
    }

    modifier onlyGateOwner() {
        require(msg.sender == gater);
        _;
    }

    function unlockShopbyMarketor() external onlyMarketManager {
        marketlock = false;
    }

    function lockShopbyMarketor() external onlyMarketManager {
        marketlock = true;
    }

    function unlockShopbyGetor() external onlyGateOwner {
        gatelock = false;
    }

    function lockShopbyGetor() external onlyGateOwner {
        gatelock = true;
    }

    function checkUnits(int24 UnitLower, int24 UnitUpper) private pure {
        require(UnitLower < UnitUpper, "lower not lower of upper unit");
        require(UnitLower >= LUnitMath.MIN_UNIT, "TLM");
        require(UnitUpper <= LUnitMath.MAX_UNIT, "TUM");
    }

    function _blockTimestamp() internal view virtual returns (uint32) {
        return uint32(block.timestamp); // truncation is desired
    }

    function coinbalance() private view returns (uint256) {
        (bool success, bytes memory data) = coin.staticcall(
            abi.encodeWithSelector(
                IERC20Minimal.balanceOf.selector,
                address(this)
            )
        );
        require(success && data.length >= 32);
        return abi.decode(data, (uint256));
    }

    function thingbalance() private view returns (uint256) {
        (bool success, bytes memory data) = thing.staticcall(
            abi.encodeWithSelector(
                IERC20Minimal.balanceOf.selector,
                address(this)
            )
        );
        require(success && data.length >= 32);
        return abi.decode(data, (uint256));
    }

    function snapshotCumulativesInside(
        int24 _unitLower,
        int24 _unitUpper
    )
        external
        view
        override
        noDelegateCall
        returns (
            int56 unitCumulativeInside,
            uint160 secondsPerinvestionInsideX128,
            uint32 secondsInside
        )
    {
        checkUnits(_unitLower, _unitUpper);

        int56 unitCumulativeLower;
        int56 unitCumulativeUpper;
        uint160 secondsPerinvestionOutsideLowerX128;
        uint160 secondsPerinvestionOutsideUpperX128;
        uint32 secondsOutsideLower;
        uint32 secondsOutsideUpper;

        {
            LUnit.Info storage lower = units[_unitLower];
            LUnit.Info storage upper = units[_unitUpper];
            bool initializedLower;
            (
                unitCumulativeLower,
                secondsPerinvestionOutsideLowerX128,
                secondsOutsideLower,
                initializedLower
            ) = (
                lower.unitCumulativeOutside,
                lower.secondsPerLiquidityOutsideX128,
                lower.secondsOutside,
                lower.initialized
            );
            require(initializedLower);

            bool initializedUpper;
            (
                unitCumulativeUpper,
                secondsPerinvestionOutsideUpperX128,
                secondsOutsideUpper,
                initializedUpper
            ) = (
                upper.unitCumulativeOutside,
                upper.secondsPerLiquidityOutsideX128,
                upper.secondsOutside,
                upper.initialized
            );
            require(initializedUpper);
        }

        State0 memory _state0 = state0;

        if (_state0.unit < _unitLower) {
            return (
                unitCumulativeLower - unitCumulativeUpper,
                secondsPerinvestionOutsideLowerX128 -
                    secondsPerinvestionOutsideUpperX128,
                secondsOutsideLower - secondsOutsideUpper
            );
        } else if (_state0.unit < _unitUpper) {
            uint32 time = _blockTimestamp();
            (
                int56 unitCumulative,
                uint160 secondsPerinvestionCumulativeX128
            ) = priceLogers.observeSingle(
                    time,
                    0,
                    _state0.unit,
                    _state0.lookerIndex,
                    investion,
                    _state0.lookerCardinality
                );
            return (
                unitCumulative - unitCumulativeLower - unitCumulativeUpper,
                secondsPerinvestionCumulativeX128 -
                    secondsPerinvestionOutsideLowerX128 -
                    secondsPerinvestionOutsideUpperX128,
                time - secondsOutsideLower - secondsOutsideUpper
            );
        } else {
            return (
                unitCumulativeUpper - unitCumulativeLower,
                secondsPerinvestionOutsideUpperX128 -
                    secondsPerinvestionOutsideLowerX128,
                secondsOutsideUpper - secondsOutsideLower
            );
        }
    }

    //// @inheritdoc IUniswapV3PoolDerivedState
    function observe(
        uint32[] calldata secondsAgos
    )
        external
        view
        override
        noDelegateCall
        returns (
            int56[] memory unitCumulatives,
            uint160[] memory secondsPerinvestionCumulativeX128s
        )
    {
        return
            priceLogers.observe(
                _blockTimestamp(),
                secondsAgos,
                state0.unit,
                state0.lookerIndex,
                investion,
                state0.lookerCardinality
            );
    }

    function increaseLookerCardinalityNext(
        uint16 lookerCardinalityNext
    ) external override lock noDelegateCall {
        uint16 lookerCardinalityNextOld = state0.lookerCardinalityNext; // for the event
        uint16 lookerCardinalityNextNew = priceLogers.grow(
            lookerCardinalityNextOld,
            lookerCardinalityNext
        );
        state0.lookerCardinalityNext = lookerCardinalityNextNew;
        if (lookerCardinalityNextOld != lookerCardinalityNextNew)
            emit IncreaseObservationCardinalityNext(
                lookerCardinalityNextOld,
                lookerCardinalityNextNew
            );
    }

    function initialize(uint160 sqrtPriceX96) external override {
        require(state0.sqrtPriceX96 == 0, "AI");

        int24 unit = LUnitMath.getUnitAtSqrtRatio(sqrtPriceX96);

        (uint16 cardinality, uint16 cardinalityNext) = priceLogers.initialize(
            _blockTimestamp()
        );

        state0 = State0({
            sqrtPriceX96: sqrtPriceX96,
            unit: unit,
            lookerIndex: 0,
            lookerCardinality: cardinality,
            lookerCardinalityNext: cardinalityNext,
            profitProtocol: 0,
            unlocked: true
        });

        emit Initialize(sqrtPriceX96, unit);
    }

    struct ModifyProofParams {
        // the address that owns the proof
        address owner;
        // the lower and upper tick of the proof
        int24 unitLower;
        int24 unitUpper;
        // any change in investion
        int128 investionDelta;
    }

    // @dev Effect some changes to a proof
    /// @param params the proof details and the change to the proof's investion to effect
    /// @return proof a storage pointer referencing the proof with the given owner and tick range
    /// @return amount0 the amount of token0 owed to the pool, negative if the pool should pay the recipient
    /// @return amount1 the amount of token1 owed to the pool, negative if the pool should pay the recipient
    function _modifyproof(
        ModifyProofParams memory params
    )
        private
        noDelegateCall
        returns (LProof.Info storage proof, int256 amount0, int256 amount1)
    {
        checkUnits(params.unitLower, params.unitUpper);

        State0 memory _state0 = state0; // SLOAD for gas optimization

        proof = _updateproof(
            params.owner,
            params.unitLower,
            params.unitUpper,
            params.investionDelta,
            _state0.unit
        );

        if (params.investionDelta != 0) {
            if (_state0.unit < params.unitLower) {
                // current tick is below the passed range; investion can only become in range by crossing from left to
                // right, when we'll need _more_ token0 (it's becoming more valuable) so user must provide it
                amount0 = LSqrtPriceMath.getAmount0Delta(
                    LUnitMath.getSqrtRatioAtUnit(params.unitLower),
                    LUnitMath.getSqrtRatioAtUnit(params.unitUpper),
                    params.investionDelta
                );
            } else if (_state0.unit < params.unitUpper) {
                // current tick is inside the passed range
                uint128 investionBefore = investion; // SLOAD for gas optimization

                // write an oracle entry
                (state0.lookerIndex, state0.lookerCardinality) = priceLogers
                    .write(
                        _state0.lookerIndex,
                        _blockTimestamp(),
                        _state0.unit,
                        investionBefore,
                        _state0.lookerCardinality,
                        _state0.lookerCardinalityNext
                    );

                amount0 = LSqrtPriceMath.getAmount0Delta(
                    _state0.sqrtPriceX96,
                    LUnitMath.getSqrtRatioAtUnit(params.unitUpper),
                    params.investionDelta
                );
                amount1 = LSqrtPriceMath.getAmount1Delta(
                    LUnitMath.getSqrtRatioAtUnit(params.unitLower),
                    _state0.sqrtPriceX96,
                    params.investionDelta
                );

                investion = LInvestionMath.addDelta(
                    investionBefore,
                    params.investionDelta
                );
            } else {
                // current tick is above the passed range; investion can only become in range by crossing from right to
                // left, when we'll need _more_ token1 (it's becoming more valuable) so user must provide it
                amount1 = LSqrtPriceMath.getAmount1Delta(
                    LUnitMath.getSqrtRatioAtUnit(params.unitLower),
                    LUnitMath.getSqrtRatioAtUnit(params.unitUpper),
                    params.investionDelta
                );
            }
        }
    }

    /// @dev Gets and updates a proof with the given investion delta
    /// @param owner the owner of the proof
    /// @param _unitLower the lower tick of the proof's tick range
    /// @param _unitUpper the upper tick of the proof's tick range
    /// @param unit the current tick, passed to avoid sloads
    function _updateproof(
        address owner,
        int24 _unitLower,
        int24 _unitUpper,
        int128 investionDelta,
        int24 unit
    ) private returns (LProof.Info storage proof) {
        proof = proofs.get(owner, _unitLower, _unitUpper);

        uint256 _feeGrowthGlobalCoinX128 = profitGrowthGlobalCoinX128; // SLOAD for gas optimization
        // uint256 _feeGrowthGlobalThingX128 = profitGrowthGlobalThingX128; // SLOAD for gas optimization

        // if we need to update the ticks, do it
        bool flippedLower;
        bool flippedUpper;
        if (investionDelta != 0) {
            uint32 time = _blockTimestamp();
            (
                int56 unitCumulative,
                uint160 secondsPerInvestionCumulativeX128
            ) = priceLogers.observeSingle(
                    time,
                    0,
                    state0.unit,
                    state0.lookerIndex,
                    investion,
                    state0.lookerCardinality
                );

            flippedLower = units.update(
                _unitLower,
                unit,
                investionDelta,
                _feeGrowthGlobalCoinX128,
                //_feeGrowthGlobalThingX128,
                secondsPerInvestionCumulativeX128,
                unitCumulative,
                time,
                false,
                maxInvestionPerUnit
            );
            flippedUpper = units.update(
                _unitUpper,
                unit,
                investionDelta,
                _feeGrowthGlobalCoinX128,
                //  _feeGrowthGlobalThingX128,
                secondsPerInvestionCumulativeX128,
                unitCumulative,
                time,
                true,
                maxInvestionPerUnit
            );

            if (flippedLower) {
                unitBitmap.flipTick(_unitLower, unitSpacing);
            }
            if (flippedUpper) {
                unitBitmap.flipTick(_unitUpper, unitSpacing);
            }
        }

        uint256 feeGrowthInside0X128 = units.getFeeGrowthInside(
            _unitLower,
            _unitUpper,
            unit,
            _feeGrowthGlobalCoinX128
            //_feeGrowthGlobalThingX128
        );

        proof.update(investionDelta, feeGrowthInside0X128);

        // clear any tick data that is no longer needed
        if (investionDelta < 0) {
            if (flippedLower) {
                units.clear(_unitLower);
            }
            if (flippedUpper) {
                units.clear(_unitUpper);
            }
        }
    }

    function mint(
        address recipient,
        int24 _unitLower,
        int24 _unitUpper,
        uint128 amount,
        bytes calldata data
    ) external override lock returns (uint256 coinamount, uint256 thingamount) {
        require(amount > 0);
        (, int256 amount0Int, int256 amount1Int) = _modifyproof(
            ModifyProofParams({
                owner: recipient,
                unitLower: _unitLower,
                unitUpper: _unitUpper,
                investionDelta: int128(amount)
            })
        );

        coinamount = uint256(amount0Int);
        thingamount = uint256(amount1Int);

        uint256 balance0Before;
        uint256 balance1Before;
        if (coinamount > 0) balance0Before = coinbalance();
        if (thingamount > 0) balance1Before = thingbalance();
        /// IUniswapV3MintCallback(msg.sender).uniswapV3MintCallback(
        ///     coinamount,
        ///     thingamount,
        ///      data
        /// );
        if (coinamount > 0)
            require(balance0Before.add(coinamount) <= coinbalance(), "M0");
        if (thingamount > 0)
            require(balance1Before.add(thingamount) <= thingbalance(), "M1");

        emit Mint(
            msg.sender,
            recipient,
            _unitLower,
            _unitUpper,
            amount,
            coinamount,
            thingamount
        );
    }

    function collect(
        address recipient,
        int24 _unitLower,
        int24 _unitUpper,
        uint128 amount0Requested
    ) external override lock returns (uint128 amount0) {
        // we don't need to checkTicks here, because invalid proofs will never have non-zero tokensOwed{0,1}
        LProof.Info storage proof = proofs.get(
            msg.sender,
            _unitLower,
            _unitUpper
        );

        amount0 = amount0Requested > proof.tokensOwed0
            ? proof.tokensOwed0
            : amount0Requested;

        if (amount0 > 0) {
            proof.tokensOwed0 -= amount0;
            TransferHelper.safeTransfer(coin, recipient, amount0);
        }

        emit Collect(msg.sender, recipient, _unitLower, _unitUpper, amount0);
    }

    //// @inheritdoc IUniswapV3PoolActions
    /// @dev noDelegateCall is applied indirectly via _modifyproof
    function burn(
        int24 _unitLower,
        int24 _unitUpper,
        uint128 amount
    ) external override lock returns (uint256 amount0, uint256 amount1) {
        (
            LProof.Info storage proof,
            int256 amount0Int,
            int256 amount1Int
        ) = _modifyproof(
                ModifyProofParams({
                    owner: msg.sender,
                    unitLower: _unitLower,
                    unitUpper: _unitUpper,
                    investionDelta: -int128(amount)
                })
            );

        amount0 = uint256(-amount0Int);
        amount1 = uint256(-amount1Int);

        if (amount0 > 0 || amount1 > 0) {
            (proof.tokensOwed0, proof.tokensOwed1) = (
                proof.tokensOwed0 + uint128(amount0),
                proof.tokensOwed1 + uint128(amount1)
            );
        }

        emit Burn(msg.sender, _unitLower, _unitUpper, amount, amount0, amount1);
    }

    struct SwapCache {
        // the protocol fee for the input token
        uint8 profitProtocol;
        // investion at the beginning of the swap
        uint128 investionStart;
        // the timestamp of the current block
        uint32 blockTimestamp;
        // the current value of the tick accumulator, computed only if we cross an initialized tick
        int56 unitCumulative;
        // the current value of seconds per investion accumulator, computed only if we cross an initialized tick
        uint160 secondsPerinvestionCumulativeX128;
        // whether we've computed and cached the above two accumulators
        bool computedLatestObservation;
    }

    // the top level state of the swap, the results of which are recorded in storage at the end
    struct SwapState {
        // the amount remaining to be swapped in/out of the input/output asset
        int256 amountSpecifiedRemaining;
        // the amount already swapped out/in of the output/input asset
        int256 amountCalculated;
        // current sqrt(price)
        uint160 sqrtPriceX96;
        // the tick associated with the current price
        int24 unit;
        // the global fee growth of the input token
        uint256 profitGrowthGlobalX128;
        // amount of input token paid as protocol fee
        uint128 protocolFee;
        // the current investion in range
        uint128 investion;
    }

    struct StepComputations {
        // the price at the beginning of the step
        uint160 sqrtPriceStartX96;
        // the next tick to swap to from the current tick in the swap direction
        int24 unitNext;
        // whether unitNext is initialized or not
        bool initialized;
        // sqrt(price) for the next tick (1/0)
        uint160 sqrtPriceNextX96;
        // how much is being swapped in in this step
        uint256 amountIn;
        // how much is being swapped out
        uint256 amountOut;
        // how much fee is being paid in
        uint256 feeAmount;
    }

    //// @inheritdoc ITTSwapV1ShopActions
    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param _gateraddress The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        address _gateraddress,
        bool zeroForOne, //true :buy,false:sell
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    )
        external
        override
        noDelegateCall
        returns (int256 amount0, int256 amount1)
    {
        bool _zeroForOne = zeroForOne;
        address _recipient = recipient;
        require(amountSpecified != 0, "AS");
        require(marketlock == false, "market lock");
        State0 memory state0Start = state0;
        address commanderaddress = TTSwapV1Customer(market)
            .getCustomerRecommander(msg.sender);
        address gateraddress = _gateraddress;
        require(state0Start.unlocked, "LOK");
        require(
            zeroForOne
                ? sqrtPriceLimitX96 < state0Start.sqrtPriceX96 &&
                    sqrtPriceLimitX96 > LUnitMath.MIN_SQRT_RATIO
                : sqrtPriceLimitX96 > state0Start.sqrtPriceX96 &&
                    sqrtPriceLimitX96 < LUnitMath.MAX_SQRT_RATIO,
            "SPL"
        );

        state0.unlocked = false;

        SwapCache memory cache = SwapCache({
            investionStart: investion,
            blockTimestamp: _blockTimestamp(),
            profitProtocol: zeroForOne
                ? (state0Start.profitProtocol % 16)
                : (state0Start.profitProtocol >> 4),
            secondsPerinvestionCumulativeX128: 0,
            unitCumulative: 0,
            computedLatestObservation: false
        });

        bool exactInput = amountSpecified > 0;

        SwapState memory state = SwapState({
            amountSpecifiedRemaining: amountSpecified,
            amountCalculated: 0,
            sqrtPriceX96: state0Start.sqrtPriceX96,
            unit: state0Start.unit,
            profitGrowthGlobalX128: profitGrowthGlobalCoinX128,
            protocolFee: 0,
            investion: cache.investionStart
        });

        // continue swapping as long as we haven't used the entire input/output and haven't reached the price limit
        while (
            state.amountSpecifiedRemaining != 0 &&
            state.sqrtPriceX96 != sqrtPriceLimitX96
        ) {
            StepComputations memory step;

            step.sqrtPriceStartX96 = state.sqrtPriceX96;

            (step.unitNext, step.initialized) = unitBitmap
                .nextInitializedTickWithinOneWord(
                    state.unit,
                    unitSpacing,
                    _zeroForOne
                );

            // ensure that we do not overshoot the min/max tick, as the tick bitmap is not aware of these bounds
            if (step.unitNext < LUnitMath.MIN_UNIT) {
                step.unitNext = LUnitMath.MIN_UNIT;
            } else if (step.unitNext > LUnitMath.MAX_UNIT) {
                step.unitNext = LUnitMath.MAX_UNIT;
            }

            // get the price for the next tick
            step.sqrtPriceNextX96 = LUnitMath.getSqrtRatioAtUnit(step.unitNext);

            // compute values to swap to the target tick, price limit, or point where input/output amount is exhausted
            (state.sqrtPriceX96, step.amountIn, step.amountOut) = LSwapMath
                .computeSwapStep(
                    state.sqrtPriceX96,
                    (
                        _zeroForOne
                            ? step.sqrtPriceNextX96 < sqrtPriceLimitX96
                            : step.sqrtPriceNextX96 > sqrtPriceLimitX96
                    )
                        ? sqrtPriceLimitX96
                        : step.sqrtPriceNextX96,
                    state.investion,
                    state.amountSpecifiedRemaining
                );

            if (exactInput) {
                state.amountSpecifiedRemaining -= (step.amountIn +
                    step.feeAmount).toInt256();
                state.amountCalculated = state.amountCalculated.sub(
                    step.amountOut.toInt256()
                );
            } else {
                state.amountSpecifiedRemaining += step.amountOut.toInt256();
                state.amountCalculated = state.amountCalculated.add(
                    (step.amountIn + step.feeAmount).toInt256()
                );
            }

            // if the protocol fee is on, calculate how much is owed, decrement feeAmount, and increment protocolFee
            if (cache.profitProtocol > 0) {
                uint256 delta = step.feeAmount / cache.profitProtocol;
                step.feeAmount -= delta;
                state.protocolFee += uint128(delta);
            }

            // update global fee tracker
            if (state.investion > 0)
                state.profitGrowthGlobalX128 += LFullMath.mulDiv(
                    step.feeAmount,
                    FixedPoint128.Q128,
                    state.investion
                );

            // shift tick if we reached the next price
            if (state.sqrtPriceX96 == step.sqrtPriceNextX96) {
                // if the tick is initialized, run the tick transition
                if (step.initialized) {
                    // check for the placeholder value, which we replace with the actual value the first time the swap
                    // crosses an initialized tick
                    if (!cache.computedLatestObservation) {
                        (
                            cache.unitCumulative,
                            cache.secondsPerinvestionCumulativeX128
                        ) = priceLogers.observeSingle(
                            cache.blockTimestamp,
                            0,
                            state0Start.unit,
                            state0Start.lookerIndex,
                            cache.investionStart,
                            state0Start.lookerCardinality
                        );
                        cache.computedLatestObservation = true;
                    }
                    //要调整
                    int128 investionNet = units.cross(
                        step.unitNext,
                        (
                            _zeroForOne
                                ? state.profitGrowthGlobalX128
                                : profitGrowthGlobalCoinX128
                        ),
                        cache.secondsPerinvestionCumulativeX128,
                        cache.unitCumulative,
                        cache.blockTimestamp
                    );
                    // if we're moving leftward, we interpret investionNet as the opposite sign
                    // safe because investionNet cannot be type(int128).min
                    if (_zeroForOne) investionNet = -investionNet;

                    state.investion = LInvestionMath.addDelta(
                        state.investion,
                        investionNet
                    );
                }

                state.unit = zeroForOne ? step.unitNext - 1 : step.unitNext;
            } else if (state.sqrtPriceX96 != step.sqrtPriceStartX96) {
                // recompute unless we're on a lower tick boundary (i.e. already transitioned ticks), and haven't moved
                state.unit = LUnitMath.getUnitAtSqrtRatio(state.sqrtPriceX96);
            }
        }

        // update tick and write an oracle entry if the tick change
        if (state.unit != state0Start.unit) {
            (uint16 lookerIndex, uint16 lookerCardinality) = priceLogers.write(
                state0Start.lookerIndex,
                cache.blockTimestamp,
                state0Start.unit,
                cache.investionStart,
                state0Start.lookerCardinality,
                state0Start.lookerCardinalityNext
            );
            (
                state0.sqrtPriceX96,
                state0.unit,
                state0.lookerIndex,
                state0.lookerCardinality
            ) = (
                state.sqrtPriceX96,
                state.unit,
                lookerIndex,
                lookerCardinality
            );
        } else {
            // otherwise just update the price
            state0.sqrtPriceX96 = state.sqrtPriceX96;
        }

        // update investion if it changed
        if (cache.investionStart != state.investion)
            investion = state.investion;

        // update fee growth global and, if necessary, protocol fees
        // overflow is acceptable, protocol has to withdraw before it hits type(uint128).max fees
        if (zeroForOne) {
            profitGrowthGlobalCoinX128 = state.profitGrowthGlobalX128;
            if (state.protocolFee > 0) {
                shopfee[gateraddress].coin +=
                    (state.protocolFee / 100) *
                    profitshares.gatorshare;
                shopfee[market].coin +=
                    (state.protocolFee / 100) *
                    profitshares.marketshare;
                if (commanderaddress != address(0)) {
                    shopfee[commanderaddress].coin +=
                        state.protocolFee *
                        profitshares.commandershare;
                    shopfee[market].coin +=
                        state.protocolFee *
                        profitshares.usershare;
                } else {
                    shopfee[gateraddress].coin +=
                        state.protocolFee *
                        profitshares.commandershare;
                    shopfee[msg.sender].coin +=
                        state.protocolFee *
                        profitshares.usershare;
                }
            }
        } else {
            //  profitGrowthGlobalThingX128 = state.profitGrowthGlobalX128;
            if (state.protocolFee > 0) {
                shopfee[gateraddress].thing +=
                    (state.protocolFee / 100) *
                    profitshares.gatorshare;
                shopfee[market].thing +=
                    (state.protocolFee / 100) *
                    profitshares.marketshare;

                if (commanderaddress != address(0)) {
                    shopfee[commanderaddress].thing +=
                        state.protocolFee *
                        profitshares.commandershare;
                    shopfee[market].thing +=
                        state.protocolFee *
                        profitshares.usershare;
                } else {
                    shopfee[gateraddress].thing +=
                        state.protocolFee *
                        profitshares.commandershare;
                    shopfee[msg.sender].thing +=
                        state.protocolFee *
                        profitshares.usershare;
                }
            }
        }

        (amount0, amount1) = zeroForOne == exactInput
            ? (
                amountSpecified - state.amountSpecifiedRemaining,
                state.amountCalculated
            )
            : (
                state.amountCalculated,
                amountSpecified - state.amountSpecifiedRemaining
            );

        // do the transfers and collect payment
        if (zeroForOne) {
            if (amount1 < 0)
                TransferHelper.safeTransfer(
                    thing,
                    _recipient,
                    uint256(-amount1)
                );

            uint256 balance0Before = coinbalance();
            ///  IUniswapV3SwapCallback(msg.sender).uniswapV3SwapCallback(
            ///      amount0,
            ///     amount1,
            ///     data
            ///  );
            require(
                balance0Before.add(uint256(amount0)) <= coinbalance(),
                "IIA"
            );
        } else {
            if (amount0 < 0)
                TransferHelper.safeTransfer(
                    coin,
                    _recipient,
                    uint256(-amount0)
                );

            uint256 balance1Before = thingbalance();
            /// IUniswapV3SwapCallback(msg.sender).uniswapV3SwapCallback(
            ///    amount0,
            ///    amount1,
            ///    data
            ///);
            require(
                balance1Before.add(uint256(amount1)) <= thingbalance(),
                "IIA"
            );
        }

        emit Swap(
            msg.sender,
            _recipient,
            amount0,
            amount1,
            state.sqrtPriceX96,
            state.investion,
            state.unit
        );
        state0.unlocked = true;
    }

    //// @inheritdoc ITTSwapV1ShopActions
    function flash(
        address recipient,
        address _gateraddress,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override lock noDelegateCall {
        uint128 _investion = investion;
        require(_investion > 0, "L");
        address commanderaddress = TTSwapV1Customer(market)
            .getCustomerRecommander(msg.sender);
        address gateraddress = _gateraddress;
        uint256 fee0 = LFullMath.mulDivRoundingUp(amount0, profit, 1e6);
        uint256 fee1 = LFullMath.mulDivRoundingUp(amount1, profit, 1e6);
        uint256 balance0Before = coinbalance();
        uint256 balance1Before = thingbalance();

        if (amount0 > 0) TransferHelper.safeTransfer(coin, recipient, amount0);
        if (amount1 > 0) TransferHelper.safeTransfer(thing, recipient, amount1);

        ///IUniswapV3FlashCallback(msg.sender).uniswapV3FlashCallback(
        ///    fee0,
        ///    fee1,
        ///    data
        ///);

        uint256 balance0After = coinbalance();
        uint256 balance1After = thingbalance();

        require(balance0Before.add(fee0) <= balance0After, "F0");
        require(balance1Before.add(fee1) <= balance1After, "F1");

        // sub is safe because we know balanceAfter is gt balanceBefore by at least fee
        uint256 paid0 = balance0After - balance0Before;
        uint256 paid1 = balance1After - balance1Before;

        if (paid0 > 0) {
            uint8 profitProtocol0 = state0.profitProtocol % 16;
            uint256 fees0 = profitProtocol0 == 0 ? 0 : paid0 / profitProtocol0;
            if (uint128(fees0) > 0) {
                shopfee[gateraddress].coin += uint128(
                    (fees0 / 100) * profitshares.gatorshare
                );
                shopfee[market].coin += uint128(
                    (fees0 / 100) * profitshares.marketshare
                );
                if (commanderaddress != address(0)) {
                    shopfee[commanderaddress].coin += uint128(
                        fees0 * profitshares.commandershare
                    );
                    shopfee[market].coin += uint128(
                        fees0 * profitshares.usershare
                    );
                } else {
                    shopfee[gateraddress].coin += uint128(
                        fees0 * profitshares.commandershare
                    );
                    shopfee[msg.sender].coin += uint8(
                        fees0 * profitshares.usershare
                    );
                }
            }
        }
        // if (paid1 > 0) {
        //     uint8 profitProtocol1 = state0.profitProtocol >> 4;
        //     uint256 fees1 = profitProtocol1 == 0 ? 0 : paid1 / profitProtocol1;
        //     if (uint128(fees1) > 0) {
        //         shopfee[gateraddress].thing += uint128(
        //             (fees1 / 100) * profitshares.gatorshare
        //         );
        //         shopfee[market].thing += uint128(
        //             (fees1 / 100) * profitshares.marketshare
        //         );
        //         if (commanderaddress != address(0)) {
        //             shopfee[commanderaddress].thing += uint128(
        //                 fees1 * profitshares.commandershare
        //             );
        //             shopfee[market].thing += uint128(
        //                 fees1 * profitshares.usershare
        //             );
        //         } else {
        //             shopfee[gateraddress].thing += uint128(
        //                 fees1 * profitshares.commandershare
        //             );
        //             shopfee[msg.sender].thing += uint8(
        //                 fees1 * profitshares.usershare
        //             );
        //         }

        //         //    profitGrowthGlobalThingX128 += LFullMath.mulDiv(
        //         //         paid1 - fees1,
        //         //         FixedPoint128.Q128,
        //         //         _investion
        //         //      );
        //     }
        // }

        // emit Flash(msg.sender, recipient, amount0, amount1, paid0, paid1);
    }

    //// @inheritdoc IUniswapV3PoolOwnerActions
    function setShopFeeProtocolbyMarketor(
        uint8 profitProtocol0,
        uint8 profitProtocol1
    ) external override lock onlyMarketManager {
        require(
            (profitProtocol0 == 0 ||
                (profitProtocol0 >= 2 && profitProtocol0 <= 10)) &&
                (profitProtocol1 == 0 ||
                    (profitProtocol1 >= 2 && profitProtocol1 <= 10))
        );
        uint8 profitProtocolOld = state0.profitProtocol;
        state0.profitProtocol = profitProtocol0 + (profitProtocol1 << 4);
        emit SetFeeProtocol(
            profitProtocolOld % 16,
            profitProtocolOld >> 4,
            profitProtocol0,
            profitProtocol1
        );
    }

    function setShopFeeProfitSharesbyMarketor(
        uint8 _marketshare,
        uint8 _gatershare,
        uint8 _commandershare,
        uint8 _usershare
    ) external override lock onlyMarketManager {
        require(
            (_marketshare + _gatershare + _commandershare + _usershare) == 100,
            "profitshare config error"
        );
        profitshares = LProfitShares.Info({
            marketshare: _marketshare,
            gatorshare: _gatershare,
            commandershare: _commandershare,
            usershare: _usershare
        });
    }

    //// @inheritdoc ITTSwapV1ShopOwnerActions
    function collectProtocol()
        external
        override
        lock
        returns (uint128 coinamount)
    {
        coinamount = shopfee[msg.sender].coin;

        if (coinamount > 0) {
            if (coinamount == protocolProfits.coin) coinamount = coinamount - 1; // ensure that the slot is not cleared, for gas savings
            shopfee[msg.sender].coin -= coinamount;
            TransferHelper.safeTransfer(coin, msg.sender, coinamount);
        }

        emit CollectProtocol(msg.sender, msg.sender, coinamount);
    }
}
