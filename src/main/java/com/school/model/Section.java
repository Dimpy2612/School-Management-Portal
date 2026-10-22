package com.school.model;

public class Section {

    private long sectionId;
    private long classId;
    private long academicYearId;
    private String sectionName;
    private String roomNumber;
    private Long classTeacherId;   // nullable
    private String status;

    // From joins
    private String className;
    private String classTeacherName;

    public long getSectionId() { return sectionId; }
    public void setSectionId(long sectionId) { this.sectionId = sectionId; }

    public long getClassId() { return classId; }
    public void setClassId(long classId) { this.classId = classId; }

    public long getAcademicYearId() { return academicYearId; }
    public void setAcademicYearId(long academicYearId) { this.academicYearId = academicYearId; }

    public String getSectionName() { return sectionName; }
    public void setSectionName(String sectionName) { this.sectionName = sectionName; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public Long getClassTeacherId() { return classTeacherId; }
    public void setClassTeacherId(Long classTeacherId) { this.classTeacherId = classTeacherId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }

    public String getClassTeacherName() { return classTeacherName; }
    public void setClassTeacherName(String classTeacherName) { this.classTeacherName = classTeacherName; }
}
