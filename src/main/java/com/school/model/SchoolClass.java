package com.school.model;

public class SchoolClass {

    private long classId;
    private int schoolId;
    private String className;
    private int classOrder;
    private String status;


    private int sectionCount;
    private int studentCount;

    public long getClassId() { return classId; }
    public void setClassId(long classId) { this.classId = classId; }

    public int getSchoolId() { return schoolId; }
    public void setSchoolId(int schoolId) { this.schoolId = schoolId; }

    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }

    public int getClassOrder() { return classOrder; }
    public void setClassOrder(int classOrder) { this.classOrder = classOrder; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getSectionCount() { return sectionCount; }
    public void setSectionCount(int sectionCount) { this.sectionCount = sectionCount; }

    public int getStudentCount() { return studentCount; }
    public void setStudentCount(int studentCount) { this.studentCount = studentCount; }
}
