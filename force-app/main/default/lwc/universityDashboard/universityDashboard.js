import { LightningElement, wire } from 'lwc';

import getCurrentUserContext
    from '@salesforce/apex/UniversityPortalController.getCurrentUserContext';

import getMyCourses
    from '@salesforce/apex/UniversityPortalController.getMyCourses';

export default class UniversityDashboard extends LightningElement {

    userData;
    error;

    myCourses = [];
    courseError;

    isLoading = true;
    isCoursesLoading = true;

    showProfile = false;

    // Get logged-in user information
    @wire(getCurrentUserContext)
    wiredUser({ data, error }) {
        this.isLoading = false;

        if (data) {
            this.userData = data;
            this.error = undefined;

            console.log('User Information:', JSON.stringify(data));

        } else if (error) {
            this.userData = undefined;
            this.error = error;

            console.error('Dashboard Error:', error);
        }
    }

    // Get courses enrolled by the logged-in student
    @wire(getMyCourses)
    wiredCourses({ data, error }) {
        this.isCoursesLoading = false;

        if (data) {
            this.myCourses = data;
            this.courseError = undefined;

            console.log('My Courses:', JSON.stringify(data));

        } else if (error) {
            this.myCourses = [];
            this.courseError = error;

            console.error('Course Loading Error:', error);
        }
    }

    // Display name
    get displayName() {
        return this.userData?.userName ||
               this.userData?.contactName ||
               'User';
    }

    // User roles
    get isStudent() {
        return this.userData?.userType === 'Student';
    }

    get isAlumni() {
        return this.userData?.userType === 'Alumni';
    }

    get isStaff() {
        return this.userData?.userType === 'Staff';
    }

    // Contact availability
    get hasContact() {
        return this.userData?.contactId != null;
    }

    // Check whether enrollments exist
    get hasCourses() {
        return this.myCourses.length > 0;
    }

    // Profile dropdown
    toggleProfile() {
        this.showProfile = !this.showProfile;
    }
}