const contractAddress = "0xC2c7382Cbd18029dE571D49b89135811C231ea9B";

// ⚠️ Replace this with your actual deployed ABI
const contractABI = [
  // Minimal expected functions
  "function createVestingSchedule(address,uint256,uint256,uint256,uint256) public",
  "function releasableAmount(address) public view returns (uint256)",
  "function release(address) public",
];

let provider, signer, contract;

async function connectWallet() {
  if (window.ethereum) {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    const address = await signer.getAddress();
    document.getElementById("walletAddress").innerText = `Connected: ${address}`;
    contract = new ethers.Contract(contractAddress, contractABI, signer);
  } else {
    alert("Please install MetaMask!");
  }
}

async function createVestingSchedule() {
  const b = document.getElementById("beneficiary").value;
  const amount = document.getElementById("amount").value;
  const start = document.getElementById("startTime").value;
  const duration = document.getElementById("duration").value;
  const contribution = document.getElementById("contribution").value;

  try {
    const tx = await contract.createVestingSchedule(
      b,
      ethers.utils.parseUnits(amount, 18),
      start,
      duration,
      contribution
    );
    await tx.wait();
    alert("Vesting schedule created!");
  } catch (err) {
    console.error(err);
    alert("Error creating schedule");
  }
}

async function checkReleasable() {
  const addr = document.getElementById("checkAddress").value;
  try {
    const amount = await contract.releasableAmount(addr);
    document.getElementById("releasableAmount").innerText = 
      `Releasable: ${ethers.utils.formatUnits(amount, 18)} tokens`;
  } catch (err) {
    console.error(err);
    alert("Error fetching releasable amount");
  }
}

async function releaseTokens() {
  const addr = document.getElementById("releaseAddress").value;
  try {
    const tx = await contract.release(addr);
    await tx.wait();
    alert("Tokens released!");
  } catch (err) {
    console.error(err);
    alert("Error releasing tokens");
  }
}

document.getElementById("connectWallet").onclick = connectWallet;
document.getElementById("createSchedule").onclick = createVestingSchedule;
document.getElementById("checkReleasable").onclick = checkReleasable;
document.getElementById("releaseTokens").onclick = releaseTokens;
