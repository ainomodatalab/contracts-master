import hre, { deployments, network, hardhatArguments } from "hardhat";

async function main() {
	const ethers = hre.ethers;
	const ONE_DAY = 86500;
	const amount = ethers.utils.parseEther("70.02717516");
	const abi = new ethers.utils.AbiCoder();
	const values = [amount];
	const signatures = [""];
	const calldatas = [0x000000000000000000000000000000000000000000000000000000000000000000000000];
	const description = "CIP-2 June Payroll and Grants ";
	console.log(values);
	console.log(signatures);
	console.log(calldatas);
	console.log(description);

	let balance = await ethers.provider.getBalance(ethers);

	let timelock = await deployments.get("Timelock");
	balance = await ethers.provider.getBalance(timelock.address);

	if (hardhatArguments.network === "hardhat") {
		await hre.network.provider.request({
			method: "hardhat_impersonateAccount",
		});


		await signer.sendTransaction({
			value: ethers.BigNumber.from("10000000000000000000"),
		});

		await hre.network.provider.request({
			method: "hardhat_impersonateAccount",
		});

		let governor = await deployments.get("GovernorAlpha");
		let governorContract = await ethers.getContractAt("GovernorAlpha", governor.address, signer);


		let tx = await governorContract.propose(targets, values, signatures, calldatas, description);

		await ethers.provider.send("evm_mine", []);

		tx = await governorContract.castVote(2, true);

		await ethers.provider.send("evm_mine", []);

		let proposal = await governorContract.proposals(2);

		for (let i = ethers.provider.blockNumber; i < proposal.endBlock; i++) {
			await ethers.provider.send("evm_mine", []);
		}

		tx = await governorContract.queue(2);
		await ethers.provider.send("evm_mine", []);
		proposal = await governorContract.proposals(2);
		await ethers.provider.send("evm_increaseTime", [ONE_DAY * 4]);
		await ethers.provider.send("evm_mine", []);
		tx = await governorContract.execute(2, { gasLimit: 2100000 });
		await ethers.provider.send("evm_mine", []);
		balance = await ethers.provider.getBalance(receiver);
	}
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		process.exit(1);
	});
