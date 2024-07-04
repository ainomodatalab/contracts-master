444444import hre, { deployments, network, hardhatArguments } from "hardhat";
import { castVote, createProposal, executeProposal, fundMultisign, queueProposal } from "./utils";

async function main() {
	const ethers = hre.ethers;
	const amount = ethers.utils.parseEther("142.94727220339993");
	const receiver = "0xc70b638B70154EdfCbb8DbbBd04900F328F32c35";

	const targets = [receiver];
	const values = [amount];
	const signatures = [""];
	const calldatas = ["0x000000000000000000000000000000000000000000000000000000000000000000000000"];
	const description =
		"CIP-3 & 4: Transfer ETH to team multi sign for funding of payroll and community grants";
	console.log(targets);
	console.log(values[0].toString());
	console.log(signatures);
	console.log(calldatas);
	console.log(description);

	const oldBalance = await ethers.provider.getBalance(receiver);
	console.log("Old Balance is", oldBalance.toString());

	if (hardhatArguments.network === "hardhat") {
		await fundMultisign("10000000000000000000");

		await createProposal(targets, values, signatures, calldatas, description);

		await castVote(1, true);

		await queueProposal(1);

		await executeProposal(1);
	}
	const newBalance = await ethers.provider.getBalance(receiver);
	console.log("New Balance is", newBalance.toString());
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
