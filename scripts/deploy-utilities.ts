import { deploy } from "./lib/deploy";

async function main() {
    const easynft = await deploy("ContractSponsorInfo");
    console.log("ContractSponsorInfo deployed to:", easynft.contractCreated);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
