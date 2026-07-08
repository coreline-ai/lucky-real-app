# Korean Legal Time Policy

## Approved policy

Korean birth input is interpreted as the Korean legal civil clock label that would have appeared on an official Korean clock at the recorded birth place and date. The engine must not reinterpret a Korean birth time as local mean time by longitude.

Longitude is used only for optional true-solar observation correction after the civil legal timestamp is resolved. That correction may shift the observed solar hour, but it must not change the legal UTC offset or daylight-saving rule used to understand the birth record itself.

The optional true-solar correction uses longitude plus the Spencer (1971) equation-of-time approximation implemented in `src/engine/adapter/time-corrector.ts`. That approximation is for hour-pillar observation correction only; it is not used as evidence for legal clock offsets, solar/lunar date conversion, or solar-term source data.

## Source-cited legal-time timeline

The fixture policy uses the following source set:

- KASI historical calendar PDF: https://harg.kasi.re.kr/pro_plus/down/200307/200307_all.pdf
- National Archives 1954 standard-time record: https://theme.archives.go.kr/next/monthly/viewMain.do?month=03&year=2011
- Donga 1961 standard-time explainer: https://www.donga.com/news/Society/article/all/20170810/85768074/1
- EncyKorea daylight-saving article: https://encykorea.aks.ac.kr/Article/E0047153
- National Archives daylight-saving decree record: https://theme.archives.go.kr/next/chronology/archiveDetail.do?evntId=0049320523&flag=1&page=93&sort=
- timeanddate 1987 clock-change page: https://www.timeanddate.com/time/change/south-korea/seoul?year=1987
- timeanddate 1988 clock-change page: https://www.timeanddate.com/time/change/south-korea/seoul?year=1988
- IANA/tzdb Asia/Seoul cross-check: https://github.com/eggert/tz/blob/main/asia

| Period / event | Approved civil-time interpretation | Fixture purpose | Primary sources |
| --- | --- | --- | --- |
| 1908 standard-time adoption | Korean legal civil time uses UTC+08:30. | Guards pre-1912 Korean legal labels from being treated as modern UTC+09:00 or longitude-derived time. | KASI PDF; IANA/tzdb cross-check. |
| 1912 standard-time change | Korean legal civil time uses UTC+09:00. | Guards the 1912 transition into the +09:00 legal standard. | KASI PDF; IANA/tzdb cross-check. |
| 1954 standard-time change | Korean legal civil time returns to UTC+08:30. | Guards 1954-1961 labels from modern +09:00 conversion. | National Archives 1954 record; Donga 1961 explainer; IANA/tzdb cross-check. |
| 1955/1956 daylight saving under +08:30 | Summer-time clock labels are one hour ahead of the +08:30 standard, i.e. UTC+09:30 during the active DST interval. | Guards DST handling while the base standard is +08:30. | EncyKorea; National Archives DST decree record; IANA/tzdb cross-check. |
| 1961 standard-time change | Korean legal civil time returns to UTC+09:00. | Guards the post-1961 legal standard. | Donga 1961 explainer; IANA/tzdb cross-check. |
| 1987 daylight saving | Active DST labels use UTC+10:00. | Guards Seoul 1987 DST hour-pillar behavior. | timeanddate 1987 page; IANA/tzdb cross-check. |
| 1988 daylight saving | Active DST labels use UTC+10:00. | Guards Seoul 1988 DST hour-pillar behavior. | timeanddate 1988 page; IANA/tzdb cross-check. |
| Post-1989 ordinary civil time | Korean legal civil time uses UTC+09:00 with no ordinary DST in the policy fixture. | Guards modern Korean inputs from host time-zone drift and accidental DST rules. | EncyKorea; IANA/tzdb cross-check. |

## Engine-facing implications

1. A Korean civil birth input must first resolve against the Korean legal clock rule for that date.
2. The host machine time zone must not affect date shifting, solar-term context, or pillar selection for Korean inputs.
3. True-solar correction is a separate observation adjustment. It may use longitude after legal civil time is known, but longitude must not choose the legal offset.
4. Daeun start-age display must allow sub-year intervals. A result below one full year is policy-valid and should be representable as age `0` with month-level metadata rather than forced to minimum age `1`.
5. Public palja/report APIs support the legal Korean-time interval beginning at solar `1908-04-01`. Raw lunar/solar conversion tables still contain earlier generated data for provenance and compatibility checks, but palja/report calculation must surface a typed unsupported-range response before leaking stack traces or raw birth payloads.
6. Standard-time transition labels are explicit: repeated labels raise `AMBIGUOUS_CIVIL_TIME`, skipped labels raise `NONEXISTENT_CIVIL_TIME`, and unsupported policy dates raise `MANSERYEOK_POLICY_ERROR`.
7. Seun and wolun are evaluated at the target timestamp, not just the target calendar year/month. Year 운 changes at exact 입춘 and month 운 changes at exact 12-jeol term timestamps.

## Fixture gate

`tests/fixtures/manseryeok-policy-cases.json` records the policy cases, Daeun edge cases, and current baseline reproductions that must survive the implementation phase. `tests/engine/policy-fixtures.test.ts` validates required IDs, source-backed legal-time rows, offset arithmetic, Daeun policy payloads, and baseline current/target payload containers. It is intentionally a pre-implementation data gate rather than a behavioral engine assertion.
