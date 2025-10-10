                
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TimeVesting is Ownable {
    struct VestingSchedule {
        address beneficiary;
        uint256 totalAmount;
        uint256 releasedAmount;
        uint256 startTime;
        uint256 duration;
        uint256 contributionScore;
    }

    IERC20 public token;
    mapping(address => VestingSchedule[]) public vestingSchedules;
    uint256 public totalVestedTokens;

    event VestingScheduleCreated(
        address indexed beneficiary,
        uint256 amount,
        uint256 startTime,
        uint256 duration,
        uint256 contributionScore
    );
    event TokensReleased(address indexed beneficiary, uint256 amount);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    function createVestingSchedule(
        address _beneficiary,
        uint256 _amount,
        uint256 _startTime,
        uint256 _duration,
        uint256 _contributionScore
    ) external onlyOwner {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_amount > 0, "Amount must be greater than 0");
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Token transfer failed"
        );

        vestingSchedules[_beneficiary].push(
            VestingSchedule({
                beneficiary: _beneficiary,
                totalAmount: _amount,
                releasedAmount: 0,
                startTime: _startTime,
                duration: _duration,
                contributionScore: _contributionScore
            })
        );

        totalVestedTokens += _amount;
        emit VestingScheduleCreated(
            _beneficiary,
            _amount,
            _startTime,
            _duration,
            _contributionScore
        );
    }

    function releaseTokens(uint256 _scheduleIndex) external {
        VestingSchedule storage schedule = vestingSchedules[msg.sender][
            _scheduleIndex
        ];
        require(
            block.timestamp >= schedule.startTime,
            "Vesting has not started yet"
        );

        uint256 unreleased = releasableAmount(msg.sender, _scheduleIndex);
        require(unreleased > 0, "No tokens to release");

        schedule.releasedAmount += unreleased;
        totalVestedTokens -= unreleased;

        require(
            token.transfer(schedule.beneficiary, unreleased),
            "Token transfer failed"
        );
        emit TokensReleased(schedule.beneficiary, unreleased);
    }

    function releasableAmount(
        address _beneficiary,
        uint256 _scheduleIndex
    ) public view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[_beneficiary][
            _scheduleIndex
        ];

        if (block.timestamp < schedule.startTime) {
            return 0;
        }

        uint256 elapsedTime = block.timestamp - schedule.startTime;
        uint256 vestedAmount = (schedule.totalAmount * elapsedTime) /
            schedule.duration;

        if (vestedAmount > schedule.totalAmount) {
            vestedAmount = schedule.totalAmount;
        }

        return vestedAmount - schedule.releasedAmount;
    }

    function getVestingSchedules(
        address _beneficiary
    ) external view returns (VestingSchedule[] memory) {
        return vestingSchedules[_beneficiary];
    }
}
