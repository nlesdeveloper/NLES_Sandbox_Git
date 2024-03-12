import { LightningElement, api } from "lwc";
import NAME_FIELD from "@salesforce/schema/Event.WhoId";
import REPEAT_FIELD from "@salesforce/schema/Event.IsRecurrence2";

export default class EventFields extends LightningElement {
  @api objectApiName;
  @api recordId;

  nameField = NAME_FIELD;
  repeatField = REPEAT_FIELD;
}
