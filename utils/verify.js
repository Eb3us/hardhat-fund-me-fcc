const { run } = require("hardhat")

const verify = async (contractAddress, args) => {
    console.log("Verifying contract...")
    try {
        run("verify:verify", {
            address: contractAddress,
            constructor: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Contract has already been verified")
        } else {
            console.log(e)
        }
    }
}

module.exports = { verify }
