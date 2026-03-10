import { api, LightningElement } from 'lwc';

const ZERO = 0;

export default class DeploymentSummaryCard extends LightningElement {
    @api cardTitle = 'Deployment Summary';
    @api totalComponents = ZERO;
    @api passedChecks = ZERO;
    @api failedChecks = ZERO;

    get statusText() {
        if (this.failedChecks > ZERO) {
            return 'Status: Action Required';
        }
        return 'Status: Ready for Deployment';
    }
}
