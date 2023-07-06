import { expect } from "chai"
import {getStringUtilsAddress,setStringUtilsAddress } from "../scripts/lib/config"

describe("test config", async function () {
    it("test set stringutils address", async function () {
        setStringUtilsAddress("a")
        expect(getStringUtilsAddress()).equals("a") 
    })
})