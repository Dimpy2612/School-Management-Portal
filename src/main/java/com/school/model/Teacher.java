package com.school.model;

import java.math.BigDecimal;
import java.sql.Date;

public class Teacher {

    private long teacherId;
    private long userId;

    private String employeeCode;
    private String username;
    private String email;

    private String firstName;
    private String lastName;
    private String phone;

    private String qualification;
    private String specialization;

    private Date joiningDate;
    private BigDecimal experienceYears;
    private Date dateOfBirth;

    private String gender;
    private String address;
    private String status;


    // ==========================================
    // TEACHER ID
    // ==========================================

    public long getTeacherId() {
        return teacherId;
    }

    public void setTeacherId(long teacherId) {
        this.teacherId = teacherId;
    }


    // ==========================================
    // USER ID
    // ==========================================

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }


    // ==========================================
    // EMPLOYEE CODE
    // ==========================================

    public String getEmployeeCode() {
        return employeeCode;
    }

    public void setEmployeeCode(String employeeCode) {
        this.employeeCode = employeeCode;
    }


    // ==========================================
    // USERNAME
    // ==========================================

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }


    // ==========================================
    // EMAIL
    // ==========================================

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }


    // ==========================================
    // FIRST NAME
    // ==========================================

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }


    // ==========================================
    // LAST NAME
    // ==========================================

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }


    // ==========================================
    // PHONE
    // ==========================================

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }


    // ==========================================
    // QUALIFICATION
    // ==========================================

    public String getQualification() {
        return qualification;
    }

    public void setQualification(String qualification) {
        this.qualification = qualification;
    }


    // ==========================================
    // SPECIALIZATION
    // ==========================================

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }


    // ==========================================
    // JOINING DATE
    // ==========================================

    public Date getJoiningDate() {
        return joiningDate;
    }

    public void setJoiningDate(Date joiningDate) {
        this.joiningDate = joiningDate;
    }


    // ==========================================
    // EXPERIENCE
    // ==========================================

    public BigDecimal getExperienceYears() {
        return experienceYears;
    }

    public void setExperienceYears(BigDecimal experienceYears) {
        this.experienceYears = experienceYears;
    }


    // ==========================================
    // DATE OF BIRTH
    // ==========================================

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }


    // ==========================================
    // GENDER
    // ==========================================

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }


    // ==========================================
    // ADDRESS
    // ==========================================

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }


    // ==========================================
    // STATUS
    // ==========================================

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
