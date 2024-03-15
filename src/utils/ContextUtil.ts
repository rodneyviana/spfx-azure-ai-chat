import { spfi, SPFx, SPFI } from "@pnp/sp";
import "@pnp/sp/sites";
import "@pnp/sp/webs";
import "@pnp/sp/lists";
import "@pnp/sp/fields";
import "@pnp/sp/items";
import "@pnp/sp/folders";
import "@pnp/sp/files";
import { IFileAddResult } from "@pnp/sp/files";
import { ListViewCommandSetContext } from "@microsoft/sp-listview-extensibility";
import { SPHttpClient, SPHttpClientResponse, ISPHttpClientOptions } from '@microsoft/sp-http';
//import { getDocument } from 'pdfjs-dist';

/*
export async function pdfToText(url: string): Promise<string> {
    const pdf = await getDocument(url).promise;
    let text = '';

    for(let i = 1; i <= pdf.numPages; i++) {
        const page = await pdf.getPage(i);
        const content = await page.getTextContent();
        text += content.items.map(item => item['str']).join(' ');
    }

    return text;
}
*/
console.log('started setting sp!');
let sp: SPFI; // = spfi().using(DefaultInit());

export function SetSiteContext(context: ListViewCommandSetContext ): void {
  sp = spfi().using(SPFx(context));
  console.log(`Setup Url: ${sp.site.toUrl()}`);
}

export function getRelativePath(absoluteUrl: string): string {
  if (absoluteUrl === undefined || absoluteUrl.substring(0, 5) !== "https") {
    return absoluteUrl;
  }
  const relativePath = absoluteUrl.substring(8 + location.host.length);
  return relativePath;
}



/**
 * This function reads a document from a given relative URL in SharePoint and returns it as a readable stream.
 *
 * @param relativePath - The relative URL of the document in SharePoint.
 * @returns A promise that resolves to a readable stream of the document content.
 */
export async function readSharePointDocumentAsStream(
  relativePath: string
): Promise<ReadableStream> {
  const file = sp.web.getFileByServerRelativePath(getRelativePath(relativePath));
  const blob = await file.getBlob();

  return blob.stream();
}

/**
 * This function reads a document from a given relative URL in SharePoint and returns it as a readable stream.
 *
 * @param relativePath - The relative URL of the document in SharePoint.
 * @returns A promise that resolves to a Blob of the document content.
 */
export async function readSharePointDocumentAsBlob(
  relativePath: string
): Promise<Blob | undefined> {
  try {
    const file = sp.web.getFileByServerRelativePath(
      getRelativePath(relativePath)
    );
    const blob = await file.getBlob();

    return blob;
  } catch (e) {
    console.trace(e);
    return undefined;
  }
}


/**
 *
 * @param relativePath - relative path to the file
 * @param text - text to be saved
 * @returns Promise<string> - relative path to the new text file
 */
export async function saveTextFile(
  relativePath: string,
  text: string
): Promise<string | undefined> {
  try {
    const pathName = relativePath.substring(0, relativePath.lastIndexOf("/"));
    const fileName = relativePath.substring(relativePath.lastIndexOf("/") + 1);
    const file: IFileAddResult = await sp.web
      .getFolderByServerRelativePath(pathName)
      .files.addUsingPath(fileName, text, { Overwrite: true });
    return file.data.ServerRelativeUrl;
  } catch (e) {
    console.trace(e);
    return undefined;
  }
}

export async function recycleFile(FileUrl: string): Promise<void> {
  try {
    const result = await sp.web.getFileByUrl(FileUrl).recycle();
    console.log(`Delete result: ${result}`);
  } catch (e) {
    console.trace(e);
  }
}

export async function fileExists(relativePath: string): Promise<boolean> {
  try {
      const file = await sp.web.getFileByServerRelativePath(
          getRelativePath(relativePath)
      );
      const exists = await file.exists();
      return exists;
  } catch (e) {
      console.trace(e);
      return false;
  }
}

export async function getTextFile(relativePath: string): Promise<string | undefined> {
try {
  const file = await sp.web.getFileByServerRelativePath(
    getRelativePath(relativePath)
  );
  const text = await file.getText();
  return text;
} catch (e) {
  console.trace(e);
  return undefined;
}
}





let g_blockFlag: boolean;
export function setBlockNavigation(block: boolean): void {
  g_blockFlag = block;
}

export function preventNavigateOut(event: BeforeUnloadEvent): void {
  // cancel the event
  if (g_blockFlag) {
    event.preventDefault();
  }
  if (g_blockFlag) {
    // required in modern browsers
    event.returnValue = "";
  } else {
    // the absence of a returnValue property on the event will guarantee the browser unload happens
    // eslint-disable-next-line dot-notation
    delete event["returnValue"];
  }
}

export function activateNavigateOut(): void {
  window.addEventListener("beforeunload", preventNavigateOut);
}

export function deactivateNavigateOut(): void {
  window.removeEventListener("beforeunload", preventNavigateOut);
}

export async function readPropertyBag(propertyBagName: string): Promise<string | undefined> {
  try {
      // Retrieve the property bag
      const propertyBag: { AllProperties: { [key: string]: string }  } = await sp.web.select('AllProperties').expand('AllProperties')();
      return propertyBag.AllProperties[propertyBagName];
  } catch (error) {
      console.error(`Error reading property bag item "${propertyBagName}": ${error}`);
      return undefined;
  }

}




export async function updatePropertyBagValue(context: ListViewCommandSetContext, key: string, value: string): Promise<void> {
    const options: ISPHttpClientOptions = {
        headers: {
            'odata-version': '3.0'
        },
        body: `<Request xmlns="http://schemas.microsoft.com/sharepoint/clientquery/2009" SchemaVersion="15.0.0.0" LibraryVersion="16.0.0.0" ApplicationName=".NET Library">
                <Actions>
                    <ObjectPath Id="1" ObjectPathId="0" />
                    <ObjectPath Id="3" ObjectPathId="2" />
                    <ObjectPath Id="5" ObjectPathId="4" />
                    <Method Name="SetFieldValue" Id="6" ObjectPathId="4">
                        <Parameters>
                            <Parameter Type="String">${key}</Parameter>
                            <Parameter Type="String">${value}</Parameter>
                        </Parameters>
                    </Method>
                    <Method Name="Update" Id="7" ObjectPathId="2" />
                </Actions>
                <ObjectPaths>
                    <StaticProperty Id="0" TypeId="{3747adcd-a3c3-41b9-bfab-4a64dd2f1e0a}" Name="Current" />
                    <Property Id="2" ParentId="0" Name="Web" />
                    <Property Id="4" ParentId="2" Name="AllProperties" />
                </ObjectPaths>
            </Request>`
    };

    await context.spHttpClient.post(`${context.pageContext.web.absoluteUrl}/_vti_bin/client.svc/ProcessQuery`, SPHttpClient.configurations.v1, options)
        .then((response: SPHttpClientResponse) => {
            console.log(response);
        });
}
