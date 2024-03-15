import * as React  from 'react';
import * as ReactDom from 'react-dom';

import { Log } from '@microsoft/sp-core-library';
import {
  BaseListViewCommandSet,
  type Command,
  type IListViewCommandSetExecuteEventParameters,
  type ListViewStateChangedEventArgs
} from '@microsoft/sp-listview-extensibility';

import { MarkdownChatBot, IMarkdownChatBotProps } from '../../components/MarkdownChatBot/MarkdownChatBot';

import { readChatSettings, setChatKeyAndEndPoint, setFormsKeyAndEndPoint, setSystemInstructions, setWelcomeMessage } from '../../utils/aiUtil';
import { SetSiteContext } from '../../utils/ContextUtil';

/**
 * If your command set uses the ClientSideComponentProperties JSON input,
 * it will be deserialized into the BaseExtension.properties object.
 * You can define an interface to describe it.
 */
export interface IAiChatCommandSetProperties {
  sampleTextOne: string;
  sampleTextTwo: string;
}

const LOG_SOURCE: string = 'AiChatCommandSet';

export default class AiChatCommandSet extends BaseListViewCommandSet<IAiChatCommandSetProperties> {
  // This private member holds a reference to the page's footer
  private domPlaceholder: HTMLDivElement;
  private component: React.ReactElement<IMarkdownChatBotProps>  | undefined;

  public async onInit(): Promise<void> {
    Log.info(LOG_SOURCE, 'Initialized AiChatCommandSet');
    console.log("OnInit started!");
    // initial state of the command's visibility
    const compareOneCommand: Command = this.tryGetCommand('COMMAND_1');
    compareOneCommand.visible = false;
    
    console.log("OnInit Setting!");
    this.context.listView.listViewStateChangedEvent.add(this, this._onListViewStateChanged);
    
    SetSiteContext(this.context);
    this.domPlaceholder = document.createElement('div');
    const chatSettings = await readChatSettings();
    setChatKeyAndEndPoint(chatSettings.azureOpenAIKey, chatSettings.azureOpenAIEndpoint);
    
    setFormsKeyAndEndPoint(chatSettings.formsKey, chatSettings.formsEndpoint);
    setSystemInstructions(chatSettings.systemInstruction);
    setWelcomeMessage(chatSettings.welcomeMessage);
    return Promise.resolve();
  }

  public createComponent(serverRelativeUrl: string): void {
    if (!this.component) {
        this.component = React.createElement(
          MarkdownChatBot,
          {
            serverRelativeUrl,
            onClose: () => this.destroyComponent()
          }
        );
    
        // eslint-disable-next-line @microsoft/spfx/pair-react-dom-render-unmount
        ReactDom.render(this.component, this.domPlaceholder);
    }
  }

  public destroyComponent(): void {
    console.log("Destroying component!")
    if (this.component) {
      ReactDom.unmountComponentAtNode(this.domPlaceholder);
      this.component = undefined;
      //this.domPlaceholder.innerText = '';
      console.log("Component destroyed!");
    }
  }

  public onExecute(event: IListViewCommandSetExecuteEventParameters): void {
    console.log("OnExecute started!");
    console.trace(event);
    const serverRelativeUrl = event.selectedRows[0]?.getValueByName('FileRef');
    console.log(`Server Relative Url: ${serverRelativeUrl}`)
    switch (event.itemId) {
      case 'COMMAND_1':
        this.createComponent(serverRelativeUrl);
        break;
      default:
        throw new Error('Unknown command');
    }
  }

  private _onListViewStateChanged = (args: ListViewStateChangedEventArgs): void => {
    Log.info(LOG_SOURCE, 'List view state changed');

    const compareOneCommand: Command = this.tryGetCommand('COMMAND_1');
    if (compareOneCommand) {
      // This command should be hidden unless exactly one row is selected.
      compareOneCommand.visible = this.context.listView.selectedRows?.length === 1;
    }

    this.raiseOnChange();
  }
}
