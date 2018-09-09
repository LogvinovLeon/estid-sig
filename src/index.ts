import { BigNumber } from "bignumber.js";
import Web3 from "web3";
const { Certificate, PrivateKey } = require("@fidm/x509");
import { hwcrypto } from "./hwcrypto";
import * as WalletJSON from "../build/contracts/Wallet.json";
const hw = hwcrypto as any;

BigNumber.config({ EXPONENTIAL_AT: 1000000 });

function hexToBase64(str: string): string {
  return btoa(
    String.fromCharCode.apply(
      null,
      str
        .replace(/\r|\n/g, "")
        .replace(/([\da-fA-F]{2}) ?/g, "0x$1 ")
        .replace(/ +$/, "")
        .split(" ")
    )
  );
}

function hexToPem(s: string): string {
  var b = hexToBase64(s);
  var pem = b.match(/.{1,64}/g).join("\n");
  return "-----BEGIN CERTIFICATE-----\n" + pem + "\n-----END CERTIFICATE-----";
}
function hexToPoint(hex: string): { x: BigNumber; y: BigNumber } {
  const x = new BigNumber("0x" + hex.substr(0, 96));
  const y = new BigNumber("0x" + hex.substr(96, 96));
  return { x, y };
}
function getHiLo(number: BigNumber): { hi: BigNumber; lo: BigNumber } {
  const mod = new BigNumber(2).pow(256);
  const lo = number.mod(mod);
  const hi = number.dividedToIntegerBy(mod);
  return { lo, hi };
}

function toHex(bigNum): string {
  const unpadded = bigNum.toString(16);
  return "0x" + unpadded.padStart(64, "0");
}

const f = async () => {
  // await hw.use("auto");
  // console.log(await hw.debug());

  // CERT
  // const cert = await hw.getCertificate({ lang: "en" });
  // const certPem = hexToPem(cert.hex);
  const certPem = `-----BEGIN CERTIFICATE-----
  MIIF2TCCA8GgAwIBAgIQbz1BDCUtRAlaeq7l64CuIDANBgkqhkiG9w0BAQsFADBj
  MQswCQYDVQQGEwJFRTEiMCAGA1UECgwZQVMgU2VydGlmaXRzZWVyaW1pc2tlc2t1
  czEXMBUGA1UEYQwOTlRSRUUtMTA3NDcwMTMxFzAVBgNVBAMMDkVTVEVJRC1TSyAy
  MDE1MB4XDTE4MDIwNzA3NDY0NVoXDTIxMDIwNTIxNTk1OVowgasxCzAJBgNVBAYT
  AkVFMSQwIgYDVQQKDBtFU1RFSUQgKERJR0ktSUQgRS1SRVNJREVOVCkxGjAYBgNV
  BAsMEWRpZ2l0YWwgc2lnbmF0dXJlMSIwIAYDVQQDDBlCTE9FTUVOLFJFTUNPLDM4
  NjEyMTYwMTE0MRAwDgYDVQQEDAdCTE9FTUVOMQ4wDAYDVQQqDAVSRU1DTzEUMBIG
  A1UEBRMLMzg2MTIxNjAxMTQwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAATISm5uwefz
  D1yBLuukIPdpt403cwE2dWXWxFedG9Ii2/ZOp2RkcxSC/TKmHr3iZDINDZ1PiZsA
  RWUWtkfF6bftAsU414eOY+jaBgM5a0y9lJTUL2kRQfni5ZJ8+IqsDGOjggHsMIIB
  6DAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIGQDBUBgNVHSAETTBLMD4GCSsGAQQB
  zh8BAjAxMC8GCCsGAQUFBwIBFiNodHRwczovL3d3dy5zay5lZS9yZXBvc2l0b29y
  aXVtL0NQUzAJBgcEAIvsQAECMB0GA1UdDgQWBBQwgBry8bJjuu4Lw9c41uyav78v
  STCBigYIKwYBBQUHAQMEfjB8MAgGBgQAjkYBATAIBgYEAI5GAQQwUQYGBACORgEF
  MEcwRRY/aHR0cHM6Ly9zay5lZS9lbi9yZXBvc2l0b3J5L2NvbmRpdGlvbnMtZm9y
  LXVzZS1vZi1jZXJ0aWZpY2F0ZXMvEwJFTjATBgYEAI5GAQYwCQYHBACORgEGATAf
  BgNVHSMEGDAWgBSzq4i8mdVipIUqCM20HXI7g3JHUTBqBggrBgEFBQcBAQReMFww
  JwYIKwYBBQUHMAGGG2h0dHA6Ly9haWEuc2suZWUvZXN0ZWlkMjAxNTAxBggrBgEF
  BQcwAoYlaHR0cDovL2Muc2suZWUvRVNURUlELVNLXzIwMTUuZGVyLmNydDA8BgNV
  HR8ENTAzMDGgL6AthitodHRwOi8vd3d3LnNrLmVlL2NybHMvZXN0ZWlkL2VzdGVp
  ZDIwMTUuY3JsMA0GCSqGSIb3DQEBCwUAA4ICAQAY3ReJDAIvrZETGKVZoOYXgPqN
  SrrR7qOOin0Jl6A4JhbzOid3VPGBTIKJZ904nnBjReSKKGlDsVKjVZ1U99HedKwX
  GEfsLC1Le7mhoBL3bsvousOb1SW078TzsqsyKAnoVJ+vUAt4mdljLiS+bo96kmNx
  3bRBkxV+JLDMUWSP6VfhuEUe/87AYPM+rfsQ3Hg4GOAtARfRYWbhMYtY4Z5hyfqq
  CNBnQqnzyGf84wwWcj1hiFJzpLqdy40oyErlKAzIysar/eV0Wr0LflwSlPwkrFUl
  mndi2NwOnyNmetVe0yojhiTxOH9kGh9clBKK7QlrupExRB4o/wVbYdZdBu/44pT+
  qVRSmL+jUQzmF9GRDEEPFm0TvQNuKlG5oAwLWvSuQH5Jh1fFTV7Y8+K5tSYe1tHh
  VgWNMQi6aD8hceVvfHMLOQDXiqa842gJ2Kyif4+0T71YI69aT5ZD3qv3VFt3yLSR
  O/AQIySkQzWjzCeXrXb6wqGrEnPwJc1qcV4jRy0a1YMJdIbRy8Om0eMWBjjXUptF
  +BZTbI/WkXqR3dsc+P7sxr+qcl7EeY/ZQSwl1NrLOfM4haTd7e383M9RPOPUeekJ
  F2JAJ+ZoCH+B+0FHIGsjG2h9ELUnkExqZt85l+JWAzIKYbj1KjYiM3pdIeivvlC6
  b5OkEikDF0vPeFDDSQ==
  -----END CERTIFICATE-----`;
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
  console.log("PkxLo, PkxHi", PkxLo, PkxHi);
  console.log("PkyLo, PkyHi", PkyLo, PkyHi);
  // const web3 = new Web3(
  //   new Web3.providers.HttpProvider("http://localhost:8545")
  // );
  // const account = "0xee48eac2d46f422dbd45cea40d0e4bf30d7ad281";
  // web3.eth.defaultAccount = account;
  // var Wallet = web3.eth.contract(WalletJSON.abi);
  // Wallet.new(
  //   PkxLo,
  //   PkxHi,
  //   PkyLo,
  //   PkyHi,
  //   {
  //     data: WalletJSON.bytecode,
  //     from: account,
  //     gas: 2000000000,
  //     gasPrice: 1
  //   },
  //   (err, contract) => {
  //     if (!contract.address) {
  //       return;
  //     }
  //     console.log(contract);
  //     contract.test_fadd(console.log);
  //   }
  // );
  // const signature = await hw.sign(
  //   cert,
  //   {
  //     type: "SHA-256",
  //     hex: "413140d54372f9baf481d4c54e2d5c7bcf28fd6087000280e07976121dd54af2"
  //   },
  //   { lang: "en" }
  // );
  // const sigHex = signature.hex;
  const sigHex =
    "718709E3E35F31C53BAD07BE8D163139DC7597F6525328BB4DE291381C17A19F09DAE38B3512B5E59AC51EA7496BB35CF816F038A6F2D22EA4C454B267087BBE4794D01303106380FB30EC8AA992BEE001ADB1EEEA84DB054902FA2A0A40D556";
  const sigPoint = hexToPoint(sigHex);
  const r = sigPoint.x;
  const s = sigPoint.y;
  const rHiLo = getHiLo(r);
  const sHiLo = getHiLo(s);
  const rlo = toHex(rHiLo.lo);
  const rhi = toHex(rHiLo.hi);
  const slo = toHex(sHiLo.lo);
  const shi = toHex(sHiLo.hi);
  console.log("rlo, rhi", rlo, rhi);
  console.log("slo, shi", slo, shi);
};
window.onload = f;
