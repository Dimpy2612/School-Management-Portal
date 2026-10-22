package com.school.model;

import java.math.BigDecimal;

public class Subject {

    private long subjectId;
    private int schoolId;
    private long classId;
    private String subjectName;
    private String subjectCode;
    private String subjectType;
    private BigDecimal maxMarks;
    private BigDecimal passingMarks;
    private String status;

    // from joins
    private String className;

    public long getSubjectId() { return subjectId; }
    public void setSubjectId(long subjectId) { this.subjectId = subjectId; }

    public int getSchoolId() { return schoolId; }
    public void setSchoolId(int schoolId) { this.schoolId = schoolId; }

    public long getClassId() { return classId; }
    public void setClassId(long classId) { this.classId = classId; }

    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }

    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }

    public String getSubjectType() { return subjectType; }
    public void setSubjectType(String subjectType) { this.subjectType = subjectType; }

    public BigDecimal getMaxMarks() { return maxMarks; }
    public void setMaxMarks(BigDecimal maxMarks) { this.maxMarks = maxMarks; }

    public BigDecimal getPassingMarks() { return passingMarks; }
    public void setPassingMarks(BigDecimal passingMarks) { this.passingMarks = passingMarks; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }
}
