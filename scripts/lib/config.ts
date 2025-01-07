import appConfigData from "../../app.config.json";
import { network } from "hardhat";

class AppConfig {
    nftFactoryProxyAddress!: string
    stringUtils!: string
}

const _appConfigs = initAppConfig()
// console.log(_appConfigs)

function initAppConfig(): Map<string, Map<string, AppConfig>> {
    const appConfigs = new Map<string, Map<string, AppConfig>>()
    for (const envEntry of Object.entries(appConfigData)) {
        const networkConfigs = new Map<string, AppConfig>()
        for (const netEntry of Object.entries(envEntry[1])) {
            networkConfigs.set(netEntry[0], Object.assign(new AppConfig(), netEntry[1]))
        }
        appConfigs.set(envEntry[0], networkConfigs)
    }
    return appConfigs
}

function getAppConfig(env: string, network: string): AppConfig {
    let envConfig = _appConfigs.get(env)
    if (!envConfig) {
        envConfig = _appConfigs.get("default")
    }

    const c = envConfig?.get(network)
    if (!c) {
        throw new Error("unknown network " + network)
    }
    return c
}

function getCurrAppConfig(): AppConfig {
    const env = process.env.ENV
    const networkName = network.name
    return getAppConfig(env ?? "default", networkName)
}

export function getNftFactoryProxyAddress(): string {
    return getCurrAppConfig().nftFactoryProxyAddress
}

export function setNftFactoryProxyAddress(address: string) {
    const c = getCurrAppConfig()
    c.nftFactoryProxyAddress = address

    const env = process.env.ENV
    const networkName = network.name
    _appConfigs.get(env ?? "default")?.set(networkName, c)
}

export function getStringUtilsAddress(): string {
    return getCurrAppConfig().stringUtils
}

export function setStringUtilsAddress(address: string) {
    const c = getCurrAppConfig()
    c.stringUtils = address

    const env = process.env.ENV
    const networkName = network.name
    _appConfigs.get(env ?? "default")?.set(networkName, c)
}

