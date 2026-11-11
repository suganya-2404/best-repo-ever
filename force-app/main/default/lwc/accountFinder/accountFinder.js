import { LightningElement } from 'lwc';

export default class AccountFinder extends LightningElement {
    annualRevenue = null;

    handleChange(event) {
        this.annualRevenue = event.target.value;
    }

    reset() {
        this.annualRevenue = null;
    }
}