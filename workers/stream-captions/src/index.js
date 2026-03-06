export default {
  async fetch(request, env) {
    if (request.method !== "POST") {
      return new Response("Method not allowed", { status: 405 });
    }

    const event = await request.json();

    if (event.status?.state === "ready") {
      const videoId = event.uid;
      const res = await fetch(
        `https://api.cloudflare.com/client/v4/accounts/${env.ACCOUNT_ID}/stream/${videoId}/captions/en/generate`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${env.API_TOKEN}`,
          },
        }
      );

      if (!res.ok) {
        console.error(
          `Caption request failed: ${res.status} ${await res.text()}`
        );
        return new Response("Caption request failed", { status: 500 });
      }
    }

    return new Response("OK");
  },
};
