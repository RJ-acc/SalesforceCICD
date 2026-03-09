import { LightningElement, wire } from 'lwc';
import getSalesDashboardData from '@salesforce/apex/ReportGenerator.getSalesDashboardData';

const ZERO = 0;

export default class SalesDashboard extends LightningElement {
    dashboardData = {};
    error;
    isLoading = true;

    @wire(getSalesDashboardData)
    wiredDashboard({ error, data }) {
        this.isLoading = false;

        if (data) {
            this.dashboardData = data;
            this.error = null;
        } else if (error) {
            this.error = error?.body?.message || 'Unable to load dashboard data';
        }
    }

    get totalAccounts() {
        return this.dashboardData.totalAccounts || ZERO;
    }

    get totalContacts() {
        return this.dashboardData.totalContacts || ZERO;
    }

    get totalOpportunities() {
        return this.dashboardData.totalOpportunities || ZERO;
    }

    get openCases() {
        return this.dashboardData.openCases || ZERO;
    }

    get pipelineValue() {
        return new Intl.NumberFormat('en-US', {
            currency: 'USD',
            style: 'currency'
        }).format(this.dashboardData.pipelineValue || ZERO);
    }

    get closedWonValue() {
        return new Intl.NumberFormat('en-US', {
            currency: 'USD',
            style: 'currency'
        }).format(this.dashboardData.closedWonValue || ZERO);
    }
}
