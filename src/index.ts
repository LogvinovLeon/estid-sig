import { BigNumber } from "bignumber.js";
const { Certificate, PrivateKey } = require("@fidm/x509");
import { hwcrypto } from "./hwcrypto";
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

const f = async () => {
  await hw.use("auto");
  console.log(await hw.debug());
  const cert = await hw.getCertificate({ lang: "en" });
  console.log("certHex", cert.hex);
  const certPem = hexToPem(cert.hex);
  console.log("certPem", certPem);
  const ed25519Cert = Certificate.fromPEM(certPem);
  const rawPubKey = ed25519Cert.publicKey.keyRaw.toString("hex").substr(2);
  console.log("rawPubKey", rawPubKey.length);
  console.log("rawPubKey", rawPubKey);
  const pubKeyPoint = hexToPoint(rawPubKey);
  console.log("pubKeyPoint", pubKeyPoint);
  const Pkx = pubKeyPoint.x;
  const Pky = pubKeyPoint.y;
  console.log("Pkx, Pky", Pkx.toString(), Pky.toString());
  const PkxHiLo = getHiLo(Pkx);
  const PkyHiLo = getHiLo(Pky);
  const PkxLo = PkxHiLo.lo;
  const PkxHi = PkxHiLo.hi;
  const PkyLo = PkyHiLo.lo;
  const PkyHi = PkyHiLo.hi;
  console.log("PkxLo, PkxHi", PkxLo.toString(), PkxHi.toString());
  console.log("PkyLo, PkyHi", PkyLo.toString(), PkyHi.toString());
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
    "EEB9131427FD0F0B7195733C60DD8A99822E6250B731E570244AFE1053226CC83BCFB2A4280B6F2A81F2A723F62A457EEE281A7E5D0EA6A14E00C1759F79FDDBD91F3994CAE97F886B1F2615C6A51839F13E1B21BECD3D21ACCACCACEED2725F";
  const sigPoint = hexToPoint(sigHex);
  const r = sigPoint.x;
  const s = sigPoint.y;
  console.log("r, s", r.toString(), s.toString());
  const rHiLo = getHiLo(r);
  const sHiLo = getHiLo(s);
  const rlo = rHiLo.lo;
  const rhi = rHiLo.hi;
  const slo = sHiLo.lo;
  const shi = sHiLo.hi;
  console.log("rlo, rhi", rlo.toString(), rhi.toString());
  console.log("slo, shi", slo.toString(), shi.toString());
};
window.onload = f;
