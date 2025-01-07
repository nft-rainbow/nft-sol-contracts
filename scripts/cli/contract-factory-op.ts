import { deployOrUpdateNftFactoryTemplate, updateTemplates } from "../lib/contract-factory"
import { Command } from 'commander';
import * as dotenv from 'dotenv';
dotenv.config()

const program = new Command();

program
    .name('nft contract factory utils')
    .description('CLI to deploy nft factory or update templates')
    .version('0.1.0');

program.command('deploy')
    .description('deploy NFTContractFactory proxy or update NFTContractFactory template if proxy already exists')
    .action(async () => {
        await deployOrUpdateNftFactoryTemplate()
    });

program.command("update_templates")
    .description('update ERC721NFTCustom or ERC1155NFTCustom templates')
    .option('--erc721', 'if update ERC721NFTCustom template', false)
    .option('--erc1155', 'if update ERC1155NFTCustom template', false)
    .option('--erc721NoEnum', 'if update ERC721NFTCustomNoEnum template', false)
    .option('--erc1155NoEnum', 'if update ERC1155NFTCustomNoEnum template', false)
    .action(async (options) => {
        await updateTemplates(options.erc721, options.erc1155, options.erc721NoEnum, options.erc1155NoEnum);
    });


program.parse();