import { api, LightningElement } from 'lwc';

const COMPLETE_STATUS = 'Done';
const ZERO = 0;

export default class ReleaseChecklist extends LightningElement {
    @api title = 'Release Checklist';

    items = [
        { id: 'one', name: 'Static Analysis', status: COMPLETE_STATUS },
        { id: 'two', name: 'Unit Tests', status: COMPLETE_STATUS },
        { id: 'three', name: 'Security Scan', status: 'Pending' }
    ];

    get completedCount() {
        let completed = ZERO;
        for (const item of this.items) {
            if (item.status === COMPLETE_STATUS) {
                completed += 1;
            }
        }
        return completed;
    }

    get completionLabel() {
        return `${this.completedCount} / ${this.items.length} completed`;
    }
}
