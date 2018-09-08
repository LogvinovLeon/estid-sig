import { hwcrypto } from "./hwcrypto";
const hw = hwcrypto as any;

function hexToBase64(str) {
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

function hexToPem(s) {
  var b = hexToBase64(s);
  var pem = b.match(/.{1,64}/g).join("\n");
  return "-----BEGIN CERTIFICATE-----\n" + pem + "\n-----END CERTIFICATE-----";
}

const f = async () => {
  await hw.use("auto");
  console.log(await hw.debug());
  const cert = await hw.getCertificate({ lang: "en" });
  console.log(cert.hex);
  console.log(hexToPem(cert.hex));
  console.log(
    await hw.sign(
      cert,
      {
        type: "SHA-256",
        hex: "413140d54372f9baf481d4c54e2d5c7bcf28fd6087000280e07976121dd54af2"
      },
      { lang: "en" }
    )
  );
};
window.onload = f;
