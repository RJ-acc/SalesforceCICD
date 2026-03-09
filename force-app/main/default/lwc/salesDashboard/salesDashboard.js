import { LightningElement, wire, track } from 'lwc';
import getSalesDashboardData from '@salesforce/apex/ReportGenerator.getSalesDashboardData';
export default class SalesDashboard extends LightningElement {
    @track dashboardData = {}; @track error; @track isLoading = true;
    @wire(getSalesDashboardData) wiredDashboard({ error, data }) {
        this.isLoading = false;
        if (data) { this.dashboardData = data; this.error = undefined; }
        else if (error) { this.error = error.body.message; }
    }
    get totalAccounts() { return this.dashboardData.totalAccounts || 0; }
    get totalContacts() { return this.dashboardData.totalContacts || 0; }
    get totalOpportunities() { return this.dashboardData.totalOpportunities || 0; }
    get openCases() { return this.dashboardData.openCases || 0; }
    get pipelineValue() { return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(this.dashboardData.pipelineValue || 0); }
    get closedWonValue() { return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(this.dashboardData.closedWonValue || 0); }
}