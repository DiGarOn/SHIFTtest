const { ethers } = require("hardhat");

async function main() {

  // const deployer = await ethers.getSigner("0xd34ea7278e6bd48defe656bbe263aef11101469c")
  const deployer = await ethers.getImpersonatedSigner("0xd34ea7278e6bd48defe656bbe263aef11101469c");
  console.log("Deploying contracts with the account:", deployer.address);

  const Vault = await ethers.getContractFactory("Vault");
  const vaultContract = await Vault.deploy(deployer.address);
  console.log("Vault address is:", vaultContract.target);

  // The amount of USDC to be transferred to the vault
  const amount_to_deploy = 897589313932n;

  const usdc = await ethers.getContractAt("USDC", "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913");
  const dai = await ethers.getContractAt("USDC", "0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb");

  console.log("owner's ballance is: ", await usdc.balanceOf(deployer.address));
  await usdc.connect(deployer).approve(vaultContract.target, amount_to_deploy);

  await vaultContract.connect(deployer).deposit(amount_to_deploy);
  console.log("vault's balance after deposit is: ", await usdc.balanceOf(vaultContract.target));

  const Strategy = await ethers.getContractFactory("Strategy");
  const strategyContract = await Strategy.deploy(vaultContract.target);
  console.log("Strategy address is:", strategyContract.target);

  await vaultContract.connect(deployer).setStrategy(strategyContract.target);

  await vaultContract.connect(deployer).launchingAStrategy();

  const amoutForExit = await strategyContract.calcAmountToExit();
  await usdc.connect(deployer).approve(vaultContract.target, amoutForExit.data);

  await vaultContract.connect(deployer).exitFromTheStrategy();
  console.log("vault's balance after redeem is: ", await usdc.balanceOf(vaultContract.target));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
