import { api, LightningElement } from 'lwc';

const ZERO = 0,
    READY_STATUS = 'Status: Ready for Deployment',
    ACTION_REQUIRED_STATUS = 'Status: Action Required';

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
