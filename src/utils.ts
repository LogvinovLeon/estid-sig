import { BigNumber } from "bignumber.js";

BigNumber.config({ EXPONENTIAL_AT: 1000000 });

export function hexToBase64(str: string): string {
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

export function hexToPem(s: string): string {
  var b = hexToBase64(s);
  var pem = b.match(/.{1,64}/g).join("\n");
  return "-----BEGIN CERTIFICATE-----\n" + pem + "\n-----END CERTIFICATE-----";
}

export function hexToPoint(hex: string): { x: BigNumber; y: BigNumber } {
  const x = new BigNumber("0x" + hex.substr(0, 96));
  const y = new BigNumber("0x" + hex.substr(96, 96));
  return { x, y };
}

export function getHiLo(number: BigNumber): { hi: BigNumber; lo: BigNumber } {
  const mod = new BigNumber(2).pow(256);
  const lo = number.mod(mod);
  const hi = number.dividedToIntegerBy(mod);
  return { lo, hi };
}

export function toHex(bigNum): string {
  const unpadded = bigNum.toString(16);
  return "0x" + unpadded.padStart(64, "0");
}
