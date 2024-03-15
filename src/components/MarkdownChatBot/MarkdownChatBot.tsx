import { DeepChat } from "deep-chat-react/dist/DeepChat";
import { fileExists, getTextFile, saveTextFile } from "../../utils/ContextUtil";
import * as React from "react";
import { convert2Text, getChatEndpoint, getChatKey, getSystemInstructions, getWelcomeMessage } from "../../utils/aiUtil";
import { MessageBar, MessageBarType, ShimmerElementType, ShimmerElementsGroup, Panel, PanelType, PrimaryButton } from "@fluentui/react";

export interface IMarkdownChatBotProps {
  serverRelativeUrl: string;
  onClose?: () => void;
}

export interface IMarkdownChatBotState {
  messages: IChatMessage[];
  error?: string;
  textFilePath?: string;
  isConverting: boolean;
}

export interface IChatMessage {
  role: string;
  content: string;
}

export class MarkdownChatBot extends React.Component<
  IMarkdownChatBotProps,
  IMarkdownChatBotState
> {
  constructor(props: IMarkdownChatBotProps) {
    super(props);

    this.state = {
      messages: [],
      isConverting: false
    };
  }

  private initialMessages: Array<{role: string, text: string}> = [];
  public initMessages(text: string): void {
    const systemInstructions = getSystemInstructions();
    const finalInstructions = systemInstructions.replace("@text", text);
    const welcomeMessage = getWelcomeMessage();
    this.initialMessages = [
      {
        role: "assistant",
        text: welcomeMessage,
      },
    ];
    const messages = [
      {
        role: "system",
        content: finalInstructions,
      },
    ];
    this.setState({ messages, isConverting: false, error: undefined });
  }
  public async loadOrCreateTextFile(serverRelativeUrl: string): Promise<void> {
    let textFilePath = serverRelativeUrl;
    if (!serverRelativeUrl.endsWith(".txt")) {
      textFilePath = `${serverRelativeUrl}.txt`;
      if (!(await fileExists(textFilePath))) {
        this.setState({ isConverting: true });
        convert2Text(serverRelativeUrl)
          .then(async (convertedText) => {
            if (convertedText) {
              const newFile = await saveTextFile(textFilePath, convertedText);
              if (newFile) {
                this.initMessages(convertedText);
                return;
              } else {
                this.setState({
                  error: "Error saving the text file",
                  isConverting: false,
                });
                return;
              }
            }
          })
          .catch((error) => {
            this.setState({ error, isConverting: false });
            return;
          });
      }
    }
    if (textFilePath.endsWith(".txt")) {
      const fileText = await getTextFile(textFilePath);
      if (fileText) {
        this.initMessages(fileText);
        return;
      }
    }
    
  }

  public async componentDidMount(): Promise<void> {
    console.log("MarkdownChatBot mounting");
    const { serverRelativeUrl } = this.props;
    return this.loadOrCreateTextFile(serverRelativeUrl);
  }

  public componentWillUnmount(): void {
    console.log("MarkdownChatBot unmounting");
  }

  public render(): JSX.Element {
    return (
      <Panel
      isOpen={true}
      onDismiss={() => {
        if (this.props.onClose) {
          this.props.onClose();
        }
      }}
      type={PanelType.medium}
      headerText="Analyze Document"
      closeButtonAriaLabel="Close"
      isLightDismiss={true}
      onRenderFooterContent={() => {
        return (
          <div>
            <PrimaryButton
              onClick={() => {
                if (this.props.onClose) {
                  this.props.onClose();
                }
              }}
              style={{ marginRight: '8px' }}
            >
              Close
            </PrimaryButton>
          </div>
        );
      }}
    >
      {this.renderBot()}
      </Panel>
    );
  }

  public renderBot(): JSX.Element {
    const { isConverting,
            error,
            messages } = this.state;
    if(messages.length === 0 && !isConverting && !error) {
      return <></>;
    }
    return (
      <div>
        { error && (
          <MessageBar
            messageBarType={MessageBarType.error}
            isMultiline={true}
            dismissButtonAriaLabel="Close"
            truncated={true}
           >
            {error}
          </MessageBar>
        )}
        { isConverting && !error && (
          <div>
          <div>Converting document to text...</div>
          <ShimmerElementsGroup
            shimmerElements={[
              { type: ShimmerElementType.line, height: 40, width: '100%' },
              { type: ShimmerElementType.gap, width: '100%', height: 300 },
            ]}
          />
          </div>
        )}
        { !isConverting && !error && (
        <DeepChat
          style={{
            borderRadius: "10px",
            borderColor: "#e4e4e4",
            background:
              "linear-gradient(90deg, rgb(239, 242, 247) 0%, 7.60286%, rgb(237, 240, 249) 15.2057%, 20.7513%, rgb(235, 239, 248) 26.297%, 27.6386%, rgb(235, 239, 248) 28.9803%, 38.2826%, rgb(231, 237, 249) 47.585%, 48.1216%, rgb(230, 236, 250) 48.6583%, 53.1306%, rgb(228, 236, 249) 57.6029%, 61.5385%, rgb(227, 234, 250) 65.4741%, 68.7835%, rgb(222, 234, 250) 72.093%, 75.7603%, rgb(219, 230, 248) 79.4275%, 82.8265%, rgb(216, 229, 248) 86.2254%, 87.8354%, rgb(213, 228, 249) 89.4454%, 91.8605%, rgb(210, 226, 249) 94.2755%, 95.4383%, rgb(209, 225, 248) 96.6011%, 98.3005%, rgb(208, 224, 247) 100%)",
          }}
          chatStyle={{ width: "100%", minWidth: "600px", height: "800px" }}
          messageStyles={{
            default: {
              ai: {
                bubble: {
                  maxWidth: "100%"
                }
              },
              }
            }
          }
          request={{
            url: getChatEndpoint(),
            method: "POST",
            headers: {
              "api-key": getChatKey(),
              "Content-Type": "application/json",
            },
            handler: async (body, signals) => {
              try {
                body.messages.forEach((value: { role: string, text: string}) => {
                  messages.push({ role: value.role, content: value.text });
                });
                this.initialMessages.push({
                  role: body.messages[0].role,
                  text: body.messages[0].text,
                });
                const fullBody = {
                  max_tokens: 4000,
                  temperature: 0.6,
                  top_p: 1,
                  stop: null,
                  messages
                };
                const response = await fetch(
                  getChatEndpoint(),
                  {
                    method: "POST",
                    headers: {
                      "api-key": getChatKey(),
                      "Content-Type": "application/json",
                    },
                    body: JSON.stringify(fullBody),
                  }
                );
                const json = await response.json();
                if (json.error) {
                  signals.onResponse({ error: json.error.message });
                  return;
                }
                // displays the response

                const JSONResponse = json.choices[0];
                if (JSONResponse.finish_reason !== "stop") {
                  signals.onResponse({
                    error: `Error ${JSONResponse.finish_reason}`,
                  }); // displays an error message
                  return;
                }
                messages.push({
                  role: JSONResponse.message.role,
                  content: JSONResponse.message.content,
                });
                this.setState({ messages });
                this.initialMessages.push({
                  role: JSONResponse.message.role,
                  text: JSONResponse.message.content,
                });
                signals.onResponse({
                  text: JSONResponse.message.content,
                  role: 'ai' // JSONResponse.message.role,
                }); // displays the response
              } catch (e) {
                signals.onResponse({ error: "Error" }); // displays an error message
              }
            },
          }}
          textInput={{ placeholder: { text: "Ask me questions about the document..." } }}
          initialMessages={this.initialMessages}
        />
        )}
      </div>
    );
  }
}

/*


        <DeepChat
          style={{
            borderRadius: "10px",
            borderColor: "#e4e4e4",
            background:
              "linear-gradient(90deg, rgb(239, 242, 247) 0%, 7.60286%, rgb(237, 240, 249) 15.2057%, 20.7513%, rgb(235, 239, 248) 26.297%, 27.6386%, rgb(235, 239, 248) 28.9803%, 38.2826%, rgb(231, 237, 249) 47.585%, 48.1216%, rgb(230, 236, 250) 48.6583%, 53.1306%, rgb(228, 236, 249) 57.6029%, 61.5385%, rgb(227, 234, 250) 65.4741%, 68.7835%, rgb(222, 234, 250) 72.093%, 75.7603%, rgb(219, 230, 248) 79.4275%, 82.8265%, rgb(216, 229, 248) 86.2254%, 87.8354%, rgb(213, 228, 249) 89.4454%, 91.8605%, rgb(210, 226, 249) 94.2755%, 95.4383%, rgb(209, 225, 248) 96.6011%, 98.3005%, rgb(208, 224, 247) 100%)",
          }}
          chatStyle={{ width: "100%", minWidth: "600px", height: "800px" }}
          messageStyles={{
            default: {
              ai: {
                bubble: {
                  maxWidth: "100%"
                }
              },
              }
            }
          }
          request={{
            url: getChatEndpoint(),
            method: "POST",
            headers: {
              "api-key": getChatKey(),
              "Content-Type": "application/json",
            },
            handler: async (body, signals) => {
              try {
                body.messages.forEach((value: { role: string, text: string}) => {
                  messages.push({ role: value.role, content: value.text });
                });
                initialMessages.push({
                  role: body.messages[0].role,
                  text: body.messages[0].text,
                });
                const fullBody = {
                  max_tokens: 4000,
                  temperature: 0.6,
                  top_p: 1,
                  stop: null,
                  messages
                };
                const response = await fetch(
                  getChatEndpoint(),
                  {
                    method: "POST",
                    headers: {
                      "api-key": getChatKey(),
                      "Content-Type": "application/json",
                    },
                    body: JSON.stringify(fullBody),
                  }
                );
                const json = await response.json();
                if (json.error) {
                  signals.onResponse({ error: json.error.message });
                  return;
                }
                // displays the response

                const JSONResponse = json.choices[0];
                if (JSONResponse.finish_reason !== "stop") {
                  signals.onResponse({
                    error: `Error ${JSONResponse.finish_reason}`,
                  }); // displays an error message
                  return;
                }
                messages.push({
                  role: JSONResponse.message.role,
                  content: JSONResponse.message.content,
                });
                this.setState({ messages });
                initialMessages.push({
                  role: JSONResponse.message.role,
                  text: JSONResponse.message.content,
                });
                signals.onResponse({
                  text: JSONResponse.message.content,
                  role: 'ai' // JSONResponse.message.role,
                }); // displays the response
              } catch (e) {
                signals.onResponse({ error: "Error" }); // displays an error message
              }
            },
          }}
          textInput={{ placeholder: { text: "Ask me questions about the document..." } }}
          initialMessages={initialMessages}
        />

*/
