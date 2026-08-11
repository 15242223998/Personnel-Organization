import request from '../utils/request'

export function getAgeDistribution() {
  return request.get('/statistics/age-distribution')
}

export function getGenderDistribution() {
  return request.get('/statistics/gender-distribution')
}

export function getEducationDistribution() {
  return request.get('/statistics/education-distribution')
}

export function getPoliticalDistribution() {
  return request.get('/statistics/political-distribution')
}

export function getPositionLevelDistribution() {
  return request.get('/statistics/position-level-distribution')
}

export function getDeptSummary() {
  return request.get('/statistics/dept-summary')
}
