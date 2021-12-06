/**
 * @File Name          : translator.js
 * @Description        :
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              :
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 6/12/2021, 6:14:55 pm
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    6/12/2021, 5:50:17 pm   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
import { LightningElement } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";

import myFunction from './gtranslator.js';


export default class Translator extends LightningElement {
    connectedCallback() {
        loadScript(this, myFunction).then(() => {
          console.log('loadedddddddddddddd');
        });
      }
}