import * as React from "react";
import { BigNumber } from "bignumber.js";
import ethUtils from "web3-utils";
import Web3 from "web3";
const { Certificate } = require("@fidm/x509");
import { promisify } from "@0xproject/utils";
import { toHex, hexToPoint, getHiLo, hexToPem } from "./utils";
import { Web3Wrapper } from "@0xproject/web3-wrapper";
import * as WalletJSON from "../build/contracts/Wallet.json";
import { hwcrypto } from "./hwcrypto";
const hw = hwcrypto as any;

interface State {
  logs: string[];
}

export class App extends React.Component<{}, State> {
  constructor(props) {
    super(props);
    this.state = {
      logs: []
    };
  }
  componentDidMount() {
    this.mainAsync();
  }
  async mainAsync(): Promise<void> {
    await hw.use("auto");
    hw.debug();
    const value = 1;
    const receiver = "0x0000000000000000000000000000000000000000";
    const hash = ethUtils.soliditySha3(
      { type: "uint256", value },
      { type: "address", value: receiver }
    );
    this.log(`hash: ${hash}`);

    // CERT
    const cert = await hw.getCertificate({ lang: "en" });
    const certPem = hexToPem(cert.hex);
    const ed25519Cert = Certificate.fromPEM(certPem);
    const rawPubKey = ed25519Cert.publicKey.keyRaw.toString("hex").substr(2);
    const pubKeyPoint = hexToPoint(rawPubKey);
    const Pkx = pubKeyPoint.x;
    const Pky = pubKeyPoint.y;
    const PkxHiLo = getHiLo(Pkx);
    const PkyHiLo = getHiLo(Pky);
    const PkxLo = toHex(PkxHiLo.lo);
    const PkxHi = toHex(PkxHiLo.hi);
    const PkyLo = toHex(PkyHiLo.lo);
    const PkyHi = toHex(PkyHiLo.hi);
    this.log("PkxLo", PkxLo);
    this.log("PkxHi", PkxHi);
    this.log("PkyLo", PkyLo);
    this.log("PkyHi", PkyHi);
    const provider = new Web3.providers.HttpProvider("http://localhost:8545");
    const web3 = new Web3(provider);
    const web3Wrapper = new Web3Wrapper(provider);
    const account = "0xee48eac2d46f422dbd45cea40d0e4bf30d7ad281";
    web3.eth.defaultAccount = account;
    var Wallet = web3.eth.contract(WalletJSON.abi);
    promisify;
    Wallet.new(
      PkxHi,
      PkxLo,
      PkyHi,
      PkyLo,
      {
        data: WalletJSON.bytecode,
        from: account,
        gas: 2000000000,
        gasPrice: 1
      },
      async (err, contract) => {
        if (!contract.address) {
          return;
        }
        // SIG
        // const signature = await hw.sign(
        //   cert,
        //   {
        //     type: "SHA-256",
        //     hex: hash
        //   },
        //   { lang: "en" }
        // );
        // const sigHex = signature.hex;
        const sigHex =
          "C884ECC7CA1B5E353ECEF4FBE46AC5719731F3E9A6B0305C36E0731C37F43FBA2585578B76B71BE6072227CED0FBF56EA724BF43B56352DB2EE316666E7E98C7E0ABBDA481B91A7050FC91F7500BA6E91E319006A4E40790F80A42A30618FBFB";
        const sigPoint = hexToPoint(sigHex);
        const r = sigPoint.x;
        const s = sigPoint.y;
        const rHiLo = getHiLo(r);
        const sHiLo = getHiLo(s);
        const rlo = toHex(rHiLo.lo);
        const rhi = toHex(rHiLo.hi);
        const slo = toHex(sHiLo.lo);
        const shi = toHex(sHiLo.hi);
        this.log(`rlo: ${rlo} rhi: ${rhi}`);
        this.log(`slo: ${slo} shi: ${shi}`);
        let txHash;
        txHash = await promisify<string>(contract.precomputeGen)({
          gas: 20000000000000
        });
        this.log("precomputeGen", txHash);
        this.log(
          JSON.stringify(
            await web3Wrapper.awaitTransactionMinedAsync(txHash),
            null,
            2
          )
        );
        txHash = await promisify<string>(contract.precomputePub)(
          PkxHi,
          PkxLo,
          PkyHi,
          PkyLo,
          {
            gas: 20000000000000
          }
        );
        this.log("precomputePub", txHash);
        this.log(
          JSON.stringify(
            await web3Wrapper.awaitTransactionMinedAsync(txHash),
            null,
            2
          )
        );
        let zeroBalance = await web3Wrapper.getBalanceInWeiAsync(receiver);
        this.log(zeroBalance);
        txHash = await web3Wrapper.sendTransactionAsync({
          from: account,
          to: contract.address,
          value: 1
        });
        this.log("Sending ETH to the walet: ", txHash);
        this.log(
          JSON.stringify(
            await web3Wrapper.awaitTransactionMinedAsync(txHash),
            null,
            2
          )
        );
        txHash = await promisify(contract.sendETH)(
          value,
          receiver,
          rhi,
          rlo,
          shi,
          slo,
          {
            gas: 20000000000000
          }
        );
        this.log("Sending ETH: ", txHash);
        this.log(
          JSON.stringify(
            await web3Wrapper.awaitTransactionMinedAsync(txHash),
            null,
            2
          )
        );
        zeroBalance = await web3Wrapper.getBalanceInWeiAsync(receiver);
        this.log(zeroBalance);
      }
    );
  }
  log(...args: any[]): void {
    this.setState({
      logs: [...this.state.logs, args.map(arg => args.toString()).join(" ")]
    });
  }
  render() {
    return (
      <div>
        {this.state.logs.map(log => (
          <p key={log}>{log}</p>
        ))}
      </div>
    );
  }
}
