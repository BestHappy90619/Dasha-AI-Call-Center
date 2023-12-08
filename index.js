import * as dasha from "@dasha.ai/sdk";

const main = async () => {
  const app = await dasha.deploy("./app");
  app.setExternal("function1", (args, conv) => {
    console.log(args);
    return "hello"
  });

  await app.start({ concurrency: 1 });

  app.queue.on("ready", async (key, conv) => {
    if (process.sandbox) {
      conv.input.name = "Andrey",
      conv.input.endpoint = process.sandbox.endpoint
    }

    conv.on("transcription", async (entry) => {
      console.log("transcription", entry)
    });

    await conv.execute();
  })

  if (process.sandbox) {
    await app.queue.push("debug");
  }

  process.on('exit', async () => {
    await app.stop();
    app.dispose();
  });
}

main()
