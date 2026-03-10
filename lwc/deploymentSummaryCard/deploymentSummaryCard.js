import { LightningElement, api } from 'lwc';

const ACTION_REQUIRED_STATUS = 'Status: Action Required',
    READY_STATUS = 'Status: Ready for Deployment',
    ZERO = 0;

export default class DeploymentSummaryCard extends LightningElement {
    @api cardTitle = 'Deployment Summary';
    @api totalComponents = ZERO;
    @api passedChecks = ZERO;
    @api failedChecks = ZERO;

    get statusText() {
        if (this.failedChecks > ZERO) {
            return ACTION_REQUIRED_STATUS;
        }
        return READY_STATUS;
    }
}