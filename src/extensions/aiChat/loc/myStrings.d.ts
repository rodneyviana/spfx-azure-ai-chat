declare interface IAiChatCommandSetStrings {
  Command1: string;
  Command2: string;
}

declare module 'AiChatCommandSetStrings' {
  const strings: IAiChatCommandSetStrings;
  export = strings;
}
