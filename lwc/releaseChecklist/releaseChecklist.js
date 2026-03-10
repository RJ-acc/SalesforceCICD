import { LightningElement, api } from 'lwc';

const COMPLETE_STATUS = 'Done',
    PENDING_STATUS = 'Pending';

export default class ReleaseChecklist extends LightningElement {
    @api title = 'Release Checklist';

    items = [
        { id: 'one', name: 'Static Analysis', status: COMPLETE_STATUS },
        { id: 'two', name: 'Unit Tests', status: COMPLETE_STATUS },
        { id: 'three', name: 'Security Scan', status: PENDING_STATUS }
    ];

    get completedCount() {
        return this.items.filter((item) => item.status === COMPLETE_STATUS).length;
    }

    get completionLabel() {
        return `${this.completedCount} / ${this.items.length} completed`;
    }
}