
import { AnalyzeDocumentOptions, AnalyzeResult, AzureKeyCredential, DocumentAnalysisClient } from "@azure/ai-form-recognizer";
import { readPropertyBag, readSharePointDocumentAsBlob } from "./ContextUtil";

export interface IChatSettings {
    formsEndpoint: string;
    formsKey: string;
    azureOpenAIEndpoint: string;
    azureOpenAIKey: string;
    systemInstruction: string;
    welcomeMessage: string;
}
  
let formsKey: string;
let formsEndpoint: string;
let systemInstruction: string;
let welcomeMessage: string;
/**
 * This function sets the system instructions.
 * @returns void
 */
export function setSystemInstructions(instructions: string): void {
    systemInstruction = instructions;
}

/**
 * This function gets the system instructions.
 * @returns The system instructions
 */
export function getSystemInstructions(): string {
    return systemInstruction;
}

const MARKDOWNCHAT_STRING = "MarkdownChat"

/**
 * This function reads IChatSettings from the property bag MarkDownChat.
 */
export async function readChatSettings(): Promise<IChatSettings> {
    let chatSettings: IChatSettings = {
        formsEndpoint: "",
        formsKey: "",
        azureOpenAIEndpoint: "",
        azureOpenAIKey: "",
        systemInstruction: "",
        welcomeMessage: ""
    };
    const chatSettingsString = await readPropertyBag(MARKDOWNCHAT_STRING);

    if (chatSettingsString) {
        chatSettings = JSON.parse(chatSettingsString);
    }
    console.log("Chat Settings: ", chatSettings);
    return chatSettings;
}

/**
 * This function sets the welcome message.
 * @param message - The welcome message
 */
export function setWelcomeMessage(message: string): void {
    welcomeMessage = message;
}

/**
 * This function gets the welcome message.
 * @returns The welcome message
 */
export function getWelcomeMessage(): string {
    return welcomeMessage;
}

/**
 * This function sets the Azure Form Recognizer key and endpoint.
 * 
 * @param key - The Azure Form Recognizer key
 * @param endpoint - The Azure Form Recognizer endpoint
 * 
 */
export function setFormsKeyAndEndPoint(key: string, endpoint: string): void {
    formsEndpoint = endpoint;
    formsKey = key;
}

/**
 * This function gets the Azure Form Recognizer key.
 * 
 * @returns The Azure Form Recognizer key
 * 
 */
export function getFormsKey(): string {
    return formsKey;
}

let chatKey: string;
let chatEndpoint: string;

/**
 * This function sets the Azure OpenAI key and endpoint.
 * 
 * @param key - The Azure OpenAI key
 * @param endpoint - The Azure OpenAI endpoint
 * 
 */
export function setChatKeyAndEndPoint(key: string, endpoint: string): void {
    chatEndpoint = endpoint;
    chatKey = key;
}

/**
 * This function gets the Azure OpenAI key.
 * 
 * @returns The Azure OpenAI key
 * 
 */ 
export function getChatKey(): string {
    return chatKey;
}

/**
 * This function gets the Azure OpenAI endpoint.
 * 
 * @returns The Azure OpenAI endpoint
 * 
 */
export function getChatEndpoint(): string {
    return chatEndpoint;
}


/**
 * This function gets the Azure Form Recognizer endpoint.
 * 
 * @returns The Azure Form Recognizer endpoint
 * 
 */
export function getFormsEndpoint(): string {
    return formsEndpoint;
}

 /**
 * This function converts a document at a given URL into text using Azure's Document Analysis Client.
 * It uses the prebuilt layout model for document analysis.
 * 
 * @param docUrl - The public URL of the document to be converted into text with access token.
 * @returns A promise that resolves to the text content of the document.
 * If no pages were extracted from the document, it returns an error message.
 */
 export async function convert2Text(docUrl: string): Promise<string> {
      const client = new DocumentAnalysisClient(formsEndpoint, new AzureKeyCredential(formsKey));

      const options: AnalyzeDocumentOptions<AnalyzeResult> = {  
            pages: "1-999"
      }
      const fileBlob = await readSharePointDocumentAsBlob(docUrl);
      if(!fileBlob) {
            console.log("Error: The document was not found.");
            throw new Error("Error: The document was not found.");
        }
      const poller = await client.beginAnalyzeDocument("prebuilt-document", fileBlob, options); 

      const {
          content,
          pages
              } = await poller.pollUntilDone();


      if (!pages || pages.length <= 0) {
          console.log("Error: No pages were extracted from the document.");
          return "Error: No pages were extracted from the document.";
      } else {
          console.log(`Pages: ${pages.length}`);
          
      }
      return content;
  }

 