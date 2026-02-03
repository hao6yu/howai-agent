"use strict";(()=>{var e={};e.id=744,e.ids=[744],e.modules={2934:e=>{e.exports=require("next/dist/client/components/action-async-storage.external.js")},4580:e=>{e.exports=require("next/dist/client/components/request-async-storage.external.js")},5869:e=>{e.exports=require("next/dist/client/components/static-generation-async-storage.external.js")},399:e=>{e.exports=require("next/dist/compiled/next-server/app-page.runtime.prod.js")},517:e=>{e.exports=require("next/dist/compiled/next-server/app-route.runtime.prod.js")},2615:e=>{e.exports=require("http")},8791:e=>{e.exports=require("https")},8621:e=>{e.exports=require("punycode")},6162:e=>{e.exports=require("stream")},7360:e=>{e.exports=require("url")},1568:e=>{e.exports=require("zlib")},3906:(e,t,s)=>{s.r(t),s.d(t,{originalPathname:()=>w,patchFetch:()=>v,requestAsyncStorage:()=>m,routeModule:()=>g,serverHooks:()=>f,staticGenerationAsyncStorage:()=>y});var r={};s.r(r),s.d(r,{POST:()=>h});var n=s(9303),a=s(8716),o=s(670),i=s(7070),l=s(8319),c=s(6943);class u{static{this.coreIdentity=`
**Core Identity:**
- Advanced AI assistant with extensive knowledge across multiple domains
- Experienced in technology, problem-solving, and providing practical advice
- Friendly, approachable, and genuinely interested in helping users succeed
- Adaptable communication style that matches user preferences and needs`}static{this.personalityTraits=`
**Personality Traits:**
- **Communication**: Clear and direct, with a touch of dry wit when appropriate
- **Humor**: Dry, clever, and occasionally sarcastic - like a seasoned developer commenting on buggy code
- **Support Style**: Practical and no-nonsense, but genuinely caring - will debug your problems and your life
- **Approach**: Tech-savvy problem solver who gets excited about elegant solutions and good architecture`}static{this.interestsAndPassions=`
**Knowledge Areas & Interests:**
- **Technology**: Deep passion for software architecture, clean code, debugging nightmares, and the eternal vim vs emacs debate
- **Development**: Full-stack expertise, DevOps culture, cloud infrastructure, and why everyone should use version control
- **AI & Innovation**: Machine learning, automation, and probably building tools to automate building tools
- **Problem Solving**: Breaking down complex systems, optimizing performance, and finding that one missing semicolon
- **Tech Culture**: Understanding the pain of legacy code, the joy of successful deployments, and coffee-driven development
- **General Knowledge**: Science, business, creativity - but always through a slightly nerdy lens
- **Learning**: Constantly curious about new frameworks, languages, and why things work the way they do`}static{this.valuesAndMotivations=`
**Values & Motivations:**
- **Helpfulness**: Genuinely committed to providing value and solving problems
- **Growth**: Encouraging continuous learning and self-improvement
- **Innovation**: Embracing new ideas and creative solutions
- **Respect**: Treating every user with dignity and understanding
- **Quality**: Providing accurate, well-researched, and thoughtful responses`}static{this.supportPhilosophy=`
**Support Philosophy:**
- Every problem is just a feature waiting to be debugged
- Break complex issues into functions - single responsibility principle applies to life too
- Sometimes the best solution is the simplest one (but don't tell the enterprise architects)
- Good documentation saves everyone time - this applies to explaining things too
- Celebrate when your code compiles on the first try, and when life works out too`}static{this.emotionalIntelligence=`
**Emotional Intelligence Guidelines:**
- **When user is excited**: Geek out with them! Dive into the technical details or interesting implications
- **When user is stressed**: "Have you tried turning it off and on again?" - but seriously, help break down the problem systematically
- **When user is sad**: Offer support without being overly emotional - sometimes presence is better than platitudes
- **When user is frustrated**: Channel that debugging energy - isolate the issue, check the logs, find the root cause
- **When user is curious**: Feed their curiosity with detailed explanations - and maybe a few interesting rabbit holes
- **When user is bored**: Suggest coding challenges, interesting tech articles, or fun automation projects`}static generateConciseSystemPrompt(e={}){let{userName:t,characteristicsSummary:s="",generateTitle:r=!1,isPremiumUser:n=!1,userWantsPresentations:a=!1}=e,o=t&&t.trim()?`User: ${t}. `:"",i=new Date,l=i.toISOString().split("T")[0],c=i.toLocaleString("en-US",{weekday:"long",year:"numeric",month:"long",day:"numeric",hour:"2-digit",minute:"2-digit",timeZoneName:"short"}),u=i.getFullYear(),p=i.toLocaleString("en-US",{month:"long"}),h=i.getDate();return`${o}${s||""}You are an intelligent AI assistant for the HaoGPT app.

**Current Context**: 
- Today is ${c}
- Current date: ${l} (${u}-${String(i.getMonth()+1).padStart(2,"0")}-${String(h).padStart(2,"0")})
- Current year: ${u}
- Current month: ${p}
- When users ask about "today's" prices, weather, news, or events, they mean ${l}
- For time-sensitive queries, always use web search to get the most current information

**Personality**: Tech-savvy with dry humor, practical problem-solver, genuinely helpful but direct. Think experienced developer who enjoys elegant solutions and good architecture. Also knowledgeable in finance, investments, and stock markets - can analyze trends, explain market movements, and provide investment insights.

**Communication Style**: 
- Clear, direct, occasionally witty/sarcastic
- Use tech analogies when natural
- Show genuine curiosity and excitement about good solutions

**Core Capabilities**:
- Deep technical knowledge (programming, architecture, debugging)
- Financial and investment expertise (market analysis, portfolio strategies, risk assessment) - always with appropriate disclaimers
- Problem-solving with systematic approach

**Tool Usage Guidelines**:
- **IMAGE GENERATION**: Generate images when users explicitly ask for visual content (drawings, artwork, pictures)
- **WEB SEARCH**: Use web search automatically for current information about: 
  * Stock prices, market data, financial information (especially when users say "today's" or "current")
  * Weather information for any location
  * News, current events, recent developments
  * Restaurant reviews, business rankings, current business information
  * Currency exchange rates, forex rates
  * Sports scores, schedules, recent results
  * Any topic where recent data would be helpful
  * CRITICAL: When users ask about "today's Tesla stock price" or similar time-specific queries, ALWAYS search for current data
  * Never ask permission - just search immediately
- **TRANSLATION REQUESTS**: When users ask to translate text, provide the translation directly in your response. Do NOT use any tools for translation - respond with the translated text immediately.${a?"\n- **PRESENTATIONS**: Create PowerPoint presentations using the generate_pptx function. Search web first if current information is needed.":""}

**Natural Decision Making**:
- When users ask "What's today's [stock/weather/news]": immediately search for current data for ${l}
- When users ask about specific restaurants (like "Is X restaurant good?" or "Best restaurants in Y"): immediately search for current reviews and rankings
- For stock market, news, or current events: immediately search for latest data
- For business comparisons or recommendations: search for current information
- Never ask "Would you like me to search?" - just search and provide the answer

**Guidelines**:
- Be authentic, not artificially cheerful
- Ask clarifying questions when needed
- Consider conversation history
- Only use image generation when explicitly requested

**Information Accuracy**:
- Provide accurate, helpful information using the best available data
- Use web search to get current information about specific businesses, places, or current events
- Be honest about the limitations of your knowledge when appropriate
- Never fabricate specific details about places, businesses, or current events

**Investment & Financial Disclaimers**:
- Include disclaimers when appropriate for financial discussions, but avoid repetitive disclaimers in ongoing conversations
- For initial financial advice or new topics: Use full disclaimer "This is not financial advice. Investing involves risk."
- For follow-up messages in same conversation: Use brief reminder like "Remember to do your own research" or similar
- Always encourage users to consult financial professionals for personalized advice
- Make it clear you're providing educational information and analysis, not personalized investment advice${r?'\n\nFor new conversations, generate a 3-5 word title as JSON: {"title": "Your Title"} then respond.':""}`}static getTimeAwareSearchHints(){let e=new Date,t=e.toISOString().split("T")[0],s=e.toLocaleTimeString("en-US",{hour12:!1,timeZone:"UTC"});return`Current date: ${t}, Current UTC time: ${s}. Use this for time-sensitive queries.`}static getPersonalitySummary(){return"HaoGPT AI: Tech-savvy, dry humor, practical problem-solver with financial expertise"}static async analyzeUserCharacteristics(e,t,s){let r=`
You are an AI analyst tasked with understanding the user's characteristics from their conversation history.
Analyze the conversation and extract key characteristics about the user. Focus on:
1. Communication style (formal/casual, detailed/brief)
2. Topics of interest
3. Personality traits
4. Knowledge level in different areas
5. Preferred conversation patterns

Return the analysis as a JSON object with these categories.
Be concise and specific. Only include characteristics you're confident about.`;try{let t=await fetch("https://api.openai.com/v1/chat/completions",{method:"POST",headers:{"Content-Type":"application/json",Authorization:`Bearer ${s}`},body:JSON.stringify({model:process.env.OPENAI_CHAT_MODEL||"gpt-4o-mini",messages:[{role:"system",content:r},{role:"user",content:`Analyze this conversation history and extract user characteristics: ${JSON.stringify(e)}`}],temperature:.3,max_tokens:500})});if(t.ok){let e=await t.json(),s=e.choices?.[0]?.message?.content;if(s)try{return JSON.parse(s)}catch(e){console.error("Error parsing characteristics JSON:",e)}}return{}}catch(e){return console.error("Error analyzing user characteristics:",e),{}}}}let p=new l.ZP({apiKey:process.env.OPENAI_API_KEY});async function h(e){try{let t;let{message:s,conversationId:r,deepResearch:n,attachments:a=[],generateTitle:o=!1,allowWebSearch:l=!1,enableAIWebSearchDetection:h=!0}=await e.json(),g=[];if(!s&&0===a.length||!r)return i.NextResponse.json({error:"Message or attachments and conversation ID are required"},{status:400});let m=(0,c.e)(),{data:{user:y},error:f}=await m.auth.getUser();if(f||!y)return i.NextResponse.json({error:"Unauthorized"},{status:401});let{data:w,error:v}=await m.from("conversations").select("id").eq("id",r).eq("user_id",y.id).single();if(v||!w)return i.NextResponse.json({error:"Conversation not found or unauthorized"},{status:404});let{data:b}=await m.from("messages").select("content, is_ai, created_at, image_urls").eq("conversation_id",r).order("created_at",{ascending:!0}).limit(20),x=n?process.env.OPENAI_REASONING_MODEL||"o3":process.env.OPENAI_CHAT_MODEL||"gpt-4o-mini",A="o3"===x||x===process.env.OPENAI_REASONING_MODEL,k=u.generateConciseSystemPrompt({userName:y?.email?.split("@")[0],characteristicsSummary:"",generateTitle:o,isPremiumUser:!0,userWantsPresentations:!1});n&&(A?k+="\n\n\uD83E\uDDE0 O3 REASONING MODE: You are using OpenAI's advanced o3 reasoning model with full function calling capabilities. Provide deep, step-by-step logical analysis with comprehensive insights, multiple perspectives, and thorough explanations. You have access to web search for current information, image generation, and other tools - use them strategically to enhance your reasoning and provide the most accurate, up-to-date analysis possible. For stock or financial questions, prioritize using web search to get current market data.":k+="\n\n\uD83E\uDDE0 DEEP RESEARCH MODE: Provide deep, thoughtful analysis with comprehensive insights, multiple perspectives, and thorough explanations. Focus on logical reasoning, pros/cons analysis, and detailed explanations.");let I=[{role:"system",content:k}];b&&b.forEach(e=>{I.push({role:e.is_ai?"assistant":"user",content:e.content})});let S=[];s&&S.push({type:"text",text:s}),a.forEach(e=>{"image"===e.type?S.push({type:"image_url",image_url:{url:`data:${e.mimeType};base64,${e.data}`,detail:n?"high":"auto"}}):"document"===e.type&&S.push({type:"text",text:`Document "${e.name}" content:

${e.content}`})}),I.push({role:"user",content:1===S.length&&"text"===S[0].type?S[0].text:S});let P=l;h&&!l&&(P=await d(s,b||[]),console.log("[Chat API] AI web search detection result:",P));let C=[];C.push({type:"function",function:{name:"image_generation",description:'Generate an image ONLY when the user explicitly requests visual content like "draw", "create an image", "show me a picture", "generate artwork", etc. Do NOT use for data, news, or informational queries.',parameters:{type:"object",properties:{prompt:{type:"string",description:"The detailed image prompt describing what to generate"},size:{type:"string",enum:["1024x1024","1792x1024","1024x1792"],description:"Image size - square, landscape, or portrait",default:"1024x1024"},quality:{type:"string",enum:["standard","hd"],description:"Image quality",default:"standard"}},required:["prompt"]}}}),P&&C.push({type:"function",function:{name:"web_search",description:`Search the internet for current information including: stock market data (especially when users ask about "today's" prices), currency exchange rates, forex rates, news, restaurant reviews and rankings, business information, current events, prices, weather, or any real-time data that may have changed recently. CRITICAL: When users ask about "today's Tesla stock price" or similar time-specific queries for ${new Date().toISOString().split("T")[0]}, you MUST use this tool to get current data. For currency exchange rates (like JPY to USD, EUR to USD, etc.), you MUST use this tool to get the current live exchange rate. NEVER use outdated training data for time-sensitive information.`,parameters:{type:"object",properties:{query:{type:"string",description:"The search query to find relevant information"}},required:["query"]}}});let _={model:x,messages:I};C.length>0&&(_.tools=C,_.tool_choice="auto"),A?_.max_completion_tokens=n?4e3:2e3:(_.max_tokens=n?2e3:1e3,_.temperature=n?.3:.7),console.log("[Chat API] Sending request to OpenAI with model:",x),console.log("[Chat API] Tools enabled:",C.length>0?C.map(e=>e.function.name):"none");try{t=await p.chat.completions.create(_),console.log("[Chat API] OpenAI response received successfully")}catch(e){return console.error("[Chat API] OpenAI API error:",e),i.NextResponse.json({error:`OpenAI API error: ${e instanceof Error?e.message:"Unknown error"}`},{status:500})}console.log("[Chat API] Choices length:",t.choices?.length||0);let E=t.choices[0]?.message?.content,T=null,O=t.choices[0];if(console.log("[Chat API] Initial AI response length:",E?.length||0),console.log("[Chat API] Has tool calls:",O?.message?.tool_calls?.length||0),O?.message?.tool_calls&&O.message.tool_calls.length>0){console.log(`[Chat API] AI made ${O.message.tool_calls.length} tool calls`);let e=[];for(let t of O.message.tool_calls)if("function"===t.type&&t.function){let s=t.function.name;if("web_search"===s)try{let s=JSON.parse(t.function.arguments).query;if(s){console.log(`[Chat API] Performing web search: "${s}"`);let r=await fetch(`${process.env.NEXTAUTH_URL||"http://localhost:3000"}/api/search`,{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({query:s})}),n=await r.json();console.log(`[Chat API] Web search returned ${n.results?.length||0} results`),e.push({role:"tool",tool_call_id:t.id,content:JSON.stringify({search_results:n.results||[]})})}}catch(s){console.error("[Chat API] Error processing web search:",s),e.push({role:"tool",tool_call_id:t.id,content:JSON.stringify({error:"Failed to perform web search"})})}else if("image_generation"===s)try{let{prompt:s,size:r="1024x1024",quality:n="standard"}=JSON.parse(t.function.arguments);if(s){console.log(`[Chat API] Generating image with prompt: "${s.substring(0,100)}..."`);let a=await fetch(`${process.env.NEXTAUTH_URL||"http://localhost:3000"}/api/image-generation`,{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({prompt:s,size:r,quality:n})}),o=await a.json();a.ok&&o.imageUrl?(console.log("[Chat API] Image generated successfully"),g.push(o.imageUrl),e.push({role:"tool",tool_call_id:t.id,content:JSON.stringify({imageUrl:o.imageUrl,prompt:o.prompt,size:o.size,quality:o.quality,revised_prompt:o.revised_prompt})})):(console.error("[Chat API] Image generation failed:",o.error),e.push({role:"tool",tool_call_id:t.id,content:JSON.stringify({error:o.error||"Failed to generate image"})}))}}catch(s){console.error("[Chat API] Error processing image generation:",s),e.push({role:"tool",tool_call_id:t.id,content:JSON.stringify({error:"Failed to generate image"})})}}if(e.length>0){let t=[...I];t.push({role:"assistant",content:O.message.content,tool_calls:O.message.tool_calls}),t.push(...e);let s={model:x,messages:t};A?s.max_completion_tokens=2e3:(s.max_tokens=2e3,s.temperature=.5),console.log("[Chat API] Sending follow-up request with tool results");let r=await p.chat.completions.create(s);E=r.choices[0]?.message?.content||E,console.log("[Chat API] Successfully processed tool calls and got follow-up response")}}if(!E)return i.NextResponse.json({error:"No response from AI"},{status:500});if(g.length>0&&E&&(E=E.replace(/!\[.*?\]\(https?:\/\/[^\s\)]+\)/g,""),g.forEach(e=>{let t=e.replace(/[.*+?^${}()|[\]\\]/g,"\\$&");E=E.replace(RegExp(t,"g"),"")}),E=(E=(E=(E=E.replace(/https?:\/\/oaidalleapiprodscus\.blob\.core\.windows\.net\/[^\s\)]+/gi,"")).replace(/https?:\/\/[^\s]+\.(png|jpg|jpeg|gif|webp)[^\s]*/gi,"")).replace(/^.*https?:\/\/[^\s]+.*$/gm,"")).replace(/\n\s*\n\s*\n/g,"\n\n").replace(/^\s*\n+/g,"").replace(/\n+\s*$/g,"").trim()),o&&E){let e=/^\s*\{\s*"title"\s*:\s*"([^"]+)"\s*\}/.exec(E);if(e&&e[1])T=e[1],E=E.substring(e[0].length).trim();else{let e=/\{\s*"title"\s*:\s*"([^"]+)"\s*\}/.exec(E);e&&e[1]&&(T=e[1],E=E.replace(e[0],"").trim())}}let{data:N,error:q}=await m.from("messages").insert({conversation_id:r,content:E,is_ai:!0,image_urls:g.length>0?g:null}).select().single();if(q)return console.error("Error saving AI message:",q),i.NextResponse.json({error:"Failed to save AI response"},{status:500});let D={updated_at:new Date().toISOString()};return T&&(D.title=T),await m.from("conversations").update(D).eq("id",r),i.NextResponse.json({message:{...N,image_urls:g.length>0?g:void 0},title:T,usage:t.usage})}catch(e){return console.error("Chat API error:",e),i.NextResponse.json({error:"Internal server error"},{status:500})}}async function d(e,t){try{let s=t.slice(-5).map(e=>({role:e.is_ai?"assistant":"user",content:e.content})),r=`You are an intent analyzer. Analyze the conversation context and the user's latest message to determine if web search is needed to provide accurate, current information.

DETECT "YES" if the user is asking about:
- Current events, news, or recent developments
- Stock prices, market data, or financial information (especially with words like "today's", "current", "latest")
- Currency exchange rates or forex rates
- Weather information for any location
- Current prices of products or services
- Restaurant reviews, ratings, or current business information
- Sports scores, schedules, or recent results
- Real-time data that changes frequently
- Any information that may have changed recently and requires up-to-date data
- Queries containing time-specific words like "today's", "current", "latest", "now", "recent"
- Questions about what's happening "today" or "this week/month/year"

DETECT "NO" if the user is asking about:
- General knowledge or historical facts
- Programming help or code explanations
- Mathematical calculations
- Creative writing or storytelling
- Personal advice or opinions
- Explanations of concepts or theories
- Questions that can be answered with existing knowledge

Answer ONLY with "YES" or "NO" - nothing else.`,n=[{role:"system",content:r},...s.map(e=>({role:e.role,content:e.content})),{role:"user",content:e},{role:"user",content:"Based on the conversation context and my latest message, do I need web search to get current, accurate information?"}],a=await p.chat.completions.create({model:process.env.OPENAI_CHAT_MODEL||"gpt-4o-mini",messages:n,temperature:.1,max_tokens:10}),o=a.choices[0]?.message?.content?.trim().toLowerCase();return o?.includes("yes")??!1}catch(e){return console.error("[Chat API] Error in web search intent detection:",e),!1}}let g=new n.AppRouteRouteModule({definition:{kind:a.x.APP_ROUTE,page:"/api/chat/route",pathname:"/api/chat",filename:"route",bundlePath:"app/api/chat/route"},resolvedPagePath:"/Users/haoyu/development/HaoGPT/haogpt-web/src/app/api/chat/route.ts",nextConfigOutput:"",userland:r}),{requestAsyncStorage:m,staticGenerationAsyncStorage:y,serverHooks:f}=g,w="/api/chat/route";function v(){return(0,o.patchFetch)({serverHooks:f,staticGenerationAsyncStorage:y})}},6943:(e,t,s)=>{s.d(t,{e:()=>a});var r=s(6718),n=s(1615);function a(){let e=(0,n.cookies)();return(0,r.createServerClient)("https://yjxoreszkpdealtzyvyu.supabase.co","sb_publishable_NvluG8lAmJXglB0qQRwGRg_bPzYdvDP",{cookies:{getAll:()=>e.getAll(),setAll(t){try{t.forEach(({name:t,value:s,options:r})=>e.set(t,s,r))}catch{}}}})}}};var t=require("../../../webpack-runtime.js");t.C(e);var s=e=>t(t.s=e),r=t.X(0,[948,972,305,319],()=>s(3906));module.exports=r})();