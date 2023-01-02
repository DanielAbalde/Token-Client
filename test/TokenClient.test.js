const { expect } = require("chai");
const { utils } = require("ethers");
const { ethers } = require("hardhat");  
const lib = require("./../scripts/TokenClient"); 
 
describe("TokenClient", function ()
{
    it("Deploy", async function(){

        [this.account0, this.account1, this.account2] = await ethers.getSigners();  
    
        this.tokenClient = await deploy("TokenClient");
        this.tokenERC20 = await deploy("TokenERC20");
        this.tokenERC721 = await deploy("TokenERC721");
        this.tokenERC1155 = await deploy("TokenERC1155"); 
        this.tokenLSP7 = await deploy("TokenLSP7");
        this.tokenLSP8 = await deploy("TokenLSP8");
 
        this.testERC20 = await deploy("TestERC20");
        this.testERC721 = await deploy("TestERC721");
        this.testERC1155 = await deploy("TestERC1155"); 
        this.testLSP7 = await deploy("TestLSP7");
        this.testLSP8 = await deploy("TestLSP8");

        console.log("Account0:", this.account0.address);
        console.log("Account1:", this.account1.address);

        console.log("TokenClient:", this.tokenClient.address);
        console.log("TokenERC20:", this.tokenERC20.address);
        console.log("TokenERC721:", this.tokenERC721.address);
        console.log("TokenERC1155:", this.tokenERC1155.address);  
        console.log("TokenLSP7:", this.tokenLSP7.address);
        console.log("TokenLSP8:", this.tokenLSP8.address); 

        console.log("TestERC20:", this.testERC20.address);
        console.log("TestERC721:", this.testERC721.address);
        console.log("TestERC1155:", this.testERC1155.address); 
        console.log("TestLSP7:", this.testLSP7.address);
        console.log("TestLSP8:", this.testLSP8.address);
    });

    it("Mint", async function(){
        
        await this.testERC20.mint(this.account0.address, 100);
        await this.testERC721.mint(this.account0.address); 
        await this.testERC721.mint(this.account0.address);  
        await this.testERC721.mint(this.account0.address); 
        await this.testERC721.mint(this.account0.address);  
        await this.testERC1155.mint(this.account0.address, 10);
        await this.testERC1155.mint(this.account0.address, 10); 
        await this.testERC1155.mint(this.account0.address, 10); 
        await this.testERC1155.mint(this.account0.address, 10); 
        await this.testLSP7.mint(this.account0.address, 100);
        await this.testLSP8.mint(this.account0.address);
        await this.testLSP8.mint(this.account0.address);

        this.tokens = [
            lib.tokenizeERC20(this.testERC20.address, 100),
            lib.tokenizeERC721(this.testERC721.address, 1),
            lib.tokenizeERC721(this.testERC721.address, 2),
            lib.tokenizeERC1155(this.testERC1155.address, 1, 10), //3
            lib.tokenizeERC1155(this.testERC1155.address, 2, 10), 
            lib.tokenizeLSP7(this.testLSP7.address, 100), //5
            lib.tokenizeLSP8(this.testLSP8.address, 1),
            lib.tokenizeLSP8(this.testLSP8.address, 2),
            lib.tokenizeSetERC721(this.testERC721.address, [3, 4]), // 8
            lib.tokenizeSetERC1155(this.testERC1155.address, [3, 4], [10, 10]),
        ]; 

    });

    it("Approve", async function(){
        
        await this.testERC20.connect(this.account0).approve(this.tokenClient.address, 100);
        await this.testERC721.connect(this.account0).approve(this.tokenClient.address, 1);
        await this.testERC721.connect(this.account0).approve(this.tokenClient.address, 2);
        await this.testERC721.connect(this.account0).approve(this.tokenClient.address, 3);
        await this.testERC721.connect(this.account0).approve(this.tokenClient.address, 4);
        await this.testERC1155.connect(this.account0).setApprovalForAll(this.tokenClient.address, true);  
        await this.testLSP7.connect(this.account0).authorizeOperator(this.tokenClient.address, 100);
        await this.testLSP8.connect(this.account0).authorizeOperator(this.tokenClient.address, intToBytes32(1)); 
        await this.testLSP8.connect(this.account0).authorizeOperator(this.tokenClient.address, intToBytes32(2)); 

    });

    it("Support standards", async function(){

        await this.tokenClient.support(this.tokenERC20.address);
        await this.tokenClient.support(this.tokenERC721.address);
        await this.tokenClient.support(this.tokenERC1155.address); 
        await this.tokenClient.support(this.tokenLSP7.address);
        await this.tokenClient.support(this.tokenLSP8.address);

        this.supportedStandards = await this.tokenClient.supportedStandards();
        expect(this.supportedStandards[0]).to.be.equal(lib.ERC20);
        expect(this.supportedStandards[1]).to.be.equal(lib.ERC721);
        expect(this.supportedStandards[2]).to.be.equal(lib.ERC1155); 
        expect(this.supportedStandards[3]).to.be.equal(lib.LSP7);
        expect(this.supportedStandards[4]).to.be.equal(lib.LSP8);
        
        await expect(this.tokenClient.support(this.tokenERC20.address))
            .to.be.revertedWith('TokenClient: tokenAbstraction already supported');

        const otherTokenERC20 = await deploy("TokenERC20");
        await expect(this.tokenClient.support(otherTokenERC20.address))
            .to.emit(this.tokenClient, 'StandardReplaced').withArgs(lib.ERC20, this.tokenERC20.address);

        await expect(this.tokenClient.unsupport(lib.ERC20))
            .to.emit(this.tokenClient, 'StandardUnsupported').withArgs(lib.ERC20);
        
        this.supportedStandards = await this.tokenClient.supportedStandards();
        expect(this.supportedStandards.length).to.be.equal(4);

        await expect(await this.tokenClient.support(this.tokenERC20.address))
            .to.emit(this.tokenClient, 'StandardSupported').withArgs(lib.ERC20);
    });

    it("Is standard", async function(){
        expect(await this.tokenClient.isStandard(lib.ERC20, this.testERC20.address)).to.be.true;
        expect(await this.tokenClient.isStandard(lib.ERC20, this.testERC721.address)).to.be.false;
        expect(await this.tokenClient.isStandard(lib.ERC20, this.testERC1155.address)).to.be.false;
        expect(await this.tokenClient.isStandard(lib.ERC721, this.testERC20.address)).to.be.false;
        expect(await this.tokenClient.isStandard(lib.ERC721, this.testERC721.address)).to.be.true;
        expect(await this.tokenClient.isStandard(lib.ERC721, this.testERC1155.address)).to.be.false;
        expect(await this.tokenClient.isStandard(lib.ERC1155, this.testERC20.address)).to.be.false;
        expect(await this.tokenClient.isStandard(lib.ERC1155, this.testERC721.address)).to.be.false;
        expect(await this.tokenClient.isStandard(lib.ERC1155, this.testERC1155.address)).to.be.true; 
        expect(await this.tokenClient.isStandard(lib.LSP7, this.testLSP7.address)).to.be.true;
        expect(await this.tokenClient.isStandard(lib.LSP8, this.testLSP8.address)).to.be.true;
    });

    it("Is owner", async function(){
        expect(await this.tokenClient.isOwner(this.tokens[0], this.account0.address)).to.be.true; 
        expect(await this.tokenClient.isOwner(this.tokens[0], this.account1.address)).to.be.false; 
        expect(await this.tokenClient.isOwner(lib.tokenizeERC20(this.testERC20.address, 20), this.account0.address)).to.be.true;  
        expect(await this.tokenClient.isOwner(lib.tokenizeERC20(this.testERC20.address, 200), this.account0.address)).to.be.false;  

        expect(await this.tokenClient.isOwner(this.tokens[1], this.account0.address)).to.be.true; 
        expect(await this.tokenClient.isOwner(this.tokens[2], this.account1.address)).to.be.false; 
        expect(await this.tokenClient.isOwner(lib.tokenizeERC721(this.testERC721.address, 33), this.account0.address)).to.be.false;  
        
        expect(await this.tokenClient.isOwnerSet(this.tokens[8], this.account0.address)).to.be.true; 
        expect(await this.tokenClient.isOwnerSet(lib.tokenizeSetERC721(this.testERC721.address, [5, 6]), this.account0.address)).to.be.false;  

        expect(await this.tokenClient.isOwner(this.tokens[3], this.account0.address)).to.be.true; 
        expect(await this.tokenClient.isOwner(this.tokens[4], this.account1.address)).to.be.false; 
        expect(await this.tokenClient.isOwnerSet(this.tokens[9], this.account0.address)).to.be.true; 
        expect(await this.tokenClient.isOwner(lib.tokenizeERC1155(this.testERC1155.address, 2, 5), this.account0.address)).to.be.true; 
        expect(await this.tokenClient.isOwner(lib.tokenizeERC1155(this.testERC1155.address, 2, 15), this.account0.address)).to.be.false; 
        expect(await this.tokenClient.isOwner(lib.tokenizeERC1155(this.testERC1155.address, 33, 10), this.account0.address)).to.be.false;  
        expect(await this.tokenClient.isOwnerSet(lib.tokenizeSetERC1155(this.testERC1155.address, [1, 2], [2, 2]), this.account0.address)).to.be.true;  
        expect(await this.tokenClient.isOwnerSet(lib.tokenizeSetERC1155(this.testERC1155.address, [1, 5], [2, 2]), this.account0.address)).to.be.false;  
        expect(await this.tokenClient.isOwnerSet(lib.tokenizeSetERC1155(this.testERC1155.address, [1, 2], [20, 20]), this.account0.address)).to.be.false;  

        expect(await this.tokenClient.isOwner(this.tokens[5], this.account0.address)).to.be.true;  
        expect(await this.tokenClient.isOwner(lib.tokenizeLSP7(this.testLSP7.address, 20), this.account0.address)).to.be.true;  
        expect(await this.tokenClient.isOwner(lib.tokenizeLSP7(this.testLSP7.address, 200), this.account0.address)).to.be.false;

        expect(await this.tokenClient.isOwner(this.tokens[6], this.account0.address)).to.be.true; 
        expect(await this.tokenClient.isOwner(this.tokens[7], this.account1.address)).to.be.false; 
        expect(await this.tokenClient.isOwner(lib.tokenizeLSP8(this.testLSP8.address, 33), this.account0.address)).to.be.false;  

    });

    it("Is approved", async function(){
        expect(await this.tokenClient.isApproved(this.tokens[0], this.account0.address, this.tokenClient.address)).to.be.true; 
        expect(await this.tokenClient.isApproved(lib.tokenizeERC20(this.testERC20.address, 20), this.account0.address, this.tokenClient.address)).to.be.true; 
        expect(await this.tokenClient.isApproved(lib.tokenizeERC20(this.testERC20.address, 200), this.account0.address, this.tokenClient.address)).to.be.false; 

        expect(await this.tokenClient.isApproved(this.tokens[1], this.account0.address, this.tokenClient.address)).to.be.true;  
        expect(await this.tokenClient.isApprovedSet(this.tokens[8], this.account0.address, this.tokenClient.address)).to.be.true;  
        
        expect(await this.tokenClient.isApproved(this.tokens[3], this.account0.address, this.tokenClient.address)).to.be.true; 
        expect(await this.tokenClient.isApproved(lib.tokenizeERC1155(this.testERC1155.address, 3, 5), this.account0.address, this.tokenClient.address)).to.be.true; 
        expect(await this.tokenClient.isApprovedSet(this.tokens[9], this.account0.address, this.tokenClient.address)).to.be.true; 

        expect(await this.tokenClient.isApproved(this.tokens[5], this.account0.address, this.tokenClient.address)).to.be.true; 
        expect(await this.tokenClient.isApproved(lib.tokenizeLSP7(this.testLSP7.address, 20), this.account0.address, this.tokenClient.address)).to.be.true; 
        expect(await this.tokenClient.isApproved(lib.tokenizeLSP7(this.testLSP7.address, 200), this.account0.address, this.tokenClient.address)).to.be.false; 
        
        expect(await this.tokenClient.isApproved(this.tokens[6], this.account0.address, this.tokenClient.address)).to.be.true;  
        expect(await this.tokenClient.isApproved(this.tokens[7], this.account0.address, this.tokenClient.address)).to.be.true;  
        
    });

    it("transfer", async function(){
        await((await this.tokenClient.transfer(this.tokens[0], this.account0.address, this.account1.address)).wait()); 
        expect((await this.testERC20.balanceOf(this.account0.address)).toNumber()).to.be.equal(0);
        expect((await this.testERC20.balanceOf(this.account1.address)).toNumber()).to.be.equal(this.tokens[0][3]);

        await((await this.tokenClient.transfer(this.tokens[1], this.account0.address, this.account1.address)).wait()); 
        expect(await this.tokenClient.isOwner(this.tokens[1], this.account1.address)).to.be.true;
        expect(await this.tokenClient.isOwner(this.tokens[1], this.account0.address)).to.be.false;

        await((await this.tokenClient.transferSet(this.tokens[8], this.account0.address, this.account1.address)).wait()); 
        expect(await this.tokenClient.isOwnerSet(this.tokens[8], this.account1.address)).to.be.true;
        expect(await this.tokenClient.isOwnerSet(this.tokens[8], this.account0.address)).to.be.false;

        await((await this.tokenClient.transfer(this.tokens[3], this.account0.address, this.account1.address)).wait()); 
        expect(await this.tokenClient.isOwner(this.tokens[3], this.account1.address)).to.be.true;
        expect(await this.tokenClient.isOwner(this.tokens[3], this.account0.address)).to.be.false;
        
        await((await this.tokenClient.transferSet(this.tokens[9], this.account0.address, this.account1.address)).wait()); 
        expect(await this.tokenClient.isOwnerSet(this.tokens[9], this.account1.address)).to.be.true;
        expect(await this.tokenClient.isOwnerSet(this.tokens[9], this.account0.address)).to.be.false;

        await((await this.tokenClient.transfer(this.tokens[5], this.account0.address, this.account1.address)).wait()); 
        expect(await this.tokenClient.isOwner(this.tokens[5], this.account1.address)).to.be.true;
        expect(await this.tokenClient.isOwner(this.tokens[5], this.account0.address)).to.be.false;
        
        await((await this.tokenClient.transfer(this.tokens[6], this.account0.address, this.account1.address)).wait()); 
        expect(await this.tokenClient.isOwner(this.tokens[6], this.account1.address)).to.be.true;
        expect(await this.tokenClient.isOwner(this.tokens[6], this.account0.address)).to.be.false;
    });

    it("Allow caller", async function(){
      
        await this.tokenClient.allowCaller(this.account1.address, true);
        
        await expect(this.tokenClient.connect(this.account2).isStandard(lib.ERC20, this.tokens[0][1]))
            .to.be.revertedWith("TokenClient: caller not allowed");

        expect(await this.tokenClient.connect(this.account1).isStandard(lib.ERC20, this.tokens[0][1])).to.be.true;

        await expect(this.tokenClient.connect(this.account2).getAllowedCallers()).to.be.reverted;

        let allows = await this.tokenClient.connect(this.account0).getAllowedCallers(); 
        expect(allows.length).to.be.equal(1);
        expect(allows[0]).to.be.equal(this.account1.address);

        await this.tokenClient.allowCaller(this.account1.address, false);
        allows = await this.tokenClient.connect(this.account0).getAllowedCallers();
        expect(allows.length).to.be.equal(0);

        await this.tokenClient.allowCaller(this.account0.address, true);

        await expect(this.tokenClient.connect(this.account1).isStandard(lib.ERC20, this.tokens[0][1]))
        .to.be.revertedWith("TokenClient: caller not allowed");
    });

    it("Example of use", async function(){
        const tokenClient = await deploy("TokenClient");

        const tokenERC20 = await deploy("TokenERC20");
        const tokenERC721 = await deploy("TokenERC721");
        const tokenERC1155 = await deploy("TokenERC1155");
      
        await tokenClient.support(tokenERC20.address);
        await tokenClient.support(tokenERC721.address);
        await tokenClient.support(tokenERC1155.address); 
      
        const contract = await deploy("ExampleOfUse", tokenClient.address);

        const example721 = await deploy("TestERC721");
        await example721.mint(this.account0.address);
        await example721.approve(tokenClient.address, 1);

        const token = lib.tokenizeERC721(example721.address, 1);
        const price = ethers.utils.parseEther("3");
        await contract.sell(token, price);

        const balance = await ethers.provider.getBalance(this.account0.address);

        await contract.connect(this.account2).buy("1", { value: price });

        const newBalance = await ethers.provider.getBalance(this.account0.address);
        expect(newBalance.sub(balance)).to.be.equal(price);

        expect(await tokenClient.isOwner(token, this.account2.address)).to.be.true;
    });
});
  
async function deploy(contractName, ...params){
    const factory = await hre.ethers.getContractFactory(contractName);
    const contract = await factory.deploy(...params); 
    await contract.deployed(); 
    return contract;
}

function intToBytes32(int){
    return ethers.utils.hexZeroPad(ethers.utils.hexlify(int), 32);
}
function bytes32ToInt(bytes32){  
    return parseInt(bytes32);
}  