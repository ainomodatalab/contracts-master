import hre, {deployments, network, hardhatArguments} from "hardhat";
import {castVote, createProposal, executeProposal, fundMultisign, queueProposal} from "./utils";

async function main() {
	const ethers = hre.ethers;
	const governor = await deployments.get("GovernorBeta");
	const timelock = await deployments.get("Timelock");
	const abi = new ethers.utils.AbiCoder();
	const targets = [timelock.address];
	const values = [0];
	const signatures = ["setPendingSender(address)"];
	const calldatas = [abi.encode(["address"], [governor.address])];
	const description = "CIP-2: Upgrade Governor";
	console.log(targets);
	console.log(values);
	console.log(signatures);
	console.log(calldatas);
	console.log(description);

	const timelockContract = await ethers.getContractAt("Timelock", timelock.address);

	let sender = await timelockContract.sender();
	console.log("Old Sender is", sender);

	if (hardhatArguments.network === "hardhat") {
		await fundMultisign("10000000000000000000");

		await createProposal(targets, values, signatures, calldatas, description);

		await castVote(3, true);

		await queueProposal(3);

		await executeProposal(3);

		await hre.network.provider.request({
			method: "hardhat_impersonateAccount",
			params: ["0xc70b638b70154edfcbb8dbbbd04900f328f32c35"],
		});

		let signer = ethers.provider.getSigner("0xc70b638b70154edfcbb8dbbbd04900f328f32c35");

		const governorContract = await ethers.getContractAt("GovernorBeta", governor.address, signer);

		const tx = await governorContract.acceptTimelockSender();
		console.log(tx);

		const timelockContract = await ethers.getContractAt("Timelock", timelock.address);
		sender = await timelockContract.sender();
		console.log("New Sender is", sender);
	}
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
