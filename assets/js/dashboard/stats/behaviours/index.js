import React, { useState, useEffect, useCallback } from 'react'
import * as storage from '../../util/storage'
import ImportedQueryUnsupportedWarning from '../imported-query-unsupported-warning'
import GoalConversions, {
  specialTitleWhenGoalFilter,
  SPECIAL_GOALS
} from './goal-conversions'
import Properties from './props'
import { FeatureSetupNotice } from '../../components/notice'
import { hasConversionGoalFilter } from '../../util/filters'
import { useSiteContext } from '../../site-context'
import { useQueryContext } from '../../query-context'
import { useUserContext } from '../../user-context'
import { DropdownTabButton, TabButton, TabWrapper } from '../../components/tabs'
import { t } from '../../../i18n'

/*global BUILD_EXTRA*/
/*global require*/
function maybeRequire() {
  if (BUILD_EXTRA) {
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    return require('../../extra/funnel')
  } else {
    return { default: null }
  }
}

const Funnel = maybeRequire().default

export const CONVERSIONS = 'conversions'
export const PROPS = 'props'
export const FUNNELS = 'funnels'

export const sectionTitles = {
  [CONVERSIONS]: t('goalConversions'),
  [PROPS]: t('customProperties'),
  [FUNNELS]: t('funnels')
}

export default function Behaviours({ importedDataInView }) {
  const { query } = useQueryContext()
  const site = useSiteContext()
  const user = useUserContext()
  const adminAccess = ['owner', 'admin', 'editor', 'super_admin'].includes(
    user.role
  )
  const tabKey = storage.getDomainScopedStorageKey('behavioursTab', site.domain)
  const funnelKey = storage.getDomainScopedStorageKey(
    'behavioursTabFunnel',
    site.domain
  )
  const [enabledModes, setEnabledModes] = useState(getEnabledModes())
  const [mode, setMode] = useState(defaultMode())
  const [loading, setLoading] = useState(true)

  const [selectedFunnel, setSelectedFunnel] = useState(defaultSelectedFunnel())

  const [showingPropsForGoalFilter, setShowingPropsForGoalFilter] =
    useState(false)

  const [skipImportedReason, setSkipImportedReason] = useState(null)

  const onGoalFilterClick = useCallback((e) => {
    const goalName = e.target.innerHTML
    const isSpecialGoal = Object.keys(SPECIAL_GOALS).includes(goalName)
    const isPageviewGoal = goalName.startsWith('Visit ')

    if (
      !isSpecialGoal &&
      !isPageviewGoal &&
      enabledModes.includes(PROPS) &&
      site.hasProps
    ) {
      setShowingPropsForGoalFilter(true)
      setMode(PROPS)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    const justRemovedGoalFilter = !hasConversionGoalFilter(query)
    if (mode === PROPS && justRemovedGoalFilter && showingPropsForGoalFilter) {
      setShowingPropsForGoalFilter(false)
      setMode(CONVERSIONS)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [hasConversionGoalFilter(query)])

  useEffect(() => {
    setMode(defaultMode())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [enabledModes])

  useEffect(() => setLoading(true), [query, mode])

  function disableMode(mode) {
    setEnabledModes(
      enabledModes.filter((m) => {
        return m !== mode
      })
    )
  }

  function setFunnelFactory(selectedFunnelName) {
    return () => {
      storage.setItem(tabKey, FUNNELS)
      storage.setItem(funnelKey, selectedFunnelName)
      setMode(FUNNELS)
      setSelectedFunnel(selectedFunnelName)
    }
  }

  function defaultSelectedFunnel() {
    const stored = storage.getItem(funnelKey)
    const storedExists = stored && site.funnels.some((f) => f.name === stored)

    if (storedExists) {
      return stored
    } else if (site.funnels.length > 0) {
      const firstAvailable = site.funnels[0].name

      storage.setItem(funnelKey, firstAvailable)
      return firstAvailable
    }
  }

  function setTabFactory(tab) {
    return () => {
      storage.setItem(tabKey, tab)
      setMode(tab)
    }
  }

  function afterFetchData(apiResponse) {
    setLoading(false)
    setSkipImportedReason(apiResponse.skip_imported_reason)
  }

  function renderConversions() {
    if (site.hasGoals) {
      return (
        <GoalConversions
          onGoalFilterClick={onGoalFilterClick}
          afterFetchData={afterFetchData}
        />
      )
    } else if (adminAccess) {
      return (
        <FeatureSetupNotice
          feature={CONVERSIONS}
          title={t('measureGoalsTitle')}
          info={t('measureGoalsInfo')}
          callToAction={{
            action: t('setUpGoals'),
            link: `/${encodeURIComponent(site.domain)}/settings/goals`
          }}
          onHideAction={onHideAction(CONVERSIONS)}
        />
      )
    } else {
      return noDataYet()
    }
  }

  function renderFunnels() {
    if (Funnel === null) {
      return featureUnavailable()
    } else if (Funnel && selectedFunnel && site.funnelsAvailable) {
      return <Funnel funnelName={selectedFunnel} />
    } else if (Funnel && adminAccess) {
      let callToAction

      if (site.funnelsAvailable) {
        callToAction = {
          action: t('setUpFunnels'),
          link: `/${encodeURIComponent(site.domain)}/settings/funnels`
        }
      } else {
        callToAction = { action: t('upgrade'), link: '/billing/choose-plan' }
      }

      return (
        <FeatureSetupNotice
          feature={FUNNELS}
          title={t('funnelTitle')}
          info={t('funnelInfo')}
          callToAction={callToAction}
          onHideAction={onHideAction(FUNNELS)}
        />
      )
    } else {
      return noDataYet()
    }
  }

  function renderProps() {
    if (site.hasProps && site.propsAvailable) {
      return <Properties afterFetchData={afterFetchData} />
    } else if (adminAccess) {
      let callToAction

      if (site.propsAvailable) {
        callToAction = {
          action: t('setUpProperties'),
          link: `/${encodeURIComponent(site.domain)}/settings/properties`
        }
      } else {
        callToAction = { action: t('upgrade'), link: '/billing/choose-plan' }
      }

      return (
        <FeatureSetupNotice
          feature={PROPS}
          title={t('propertiesTitle')}
          info={t('propertiesInfo')}
          callToAction={callToAction}
          onHideAction={onHideAction(PROPS)}
        />
      )
    } else {
      return noDataYet()
    }
  }

  function noDataYet() {
    return (
      <div className="font-medium text-gray-500 dark:text-gray-400 py-12 text-center">
        {t('noDataYet')}
      </div>
    )
  }

  function featureUnavailable() {
    return (
      <div className="font-medium text-gray-500 dark:text-gray-400 py-12 text-center">
        {t('unavailable')}
      </div>
    )
  }

  function onHideAction(mode) {
    return () => {
      disableMode(mode)
    }
  }

  function renderContent() {
    switch (mode) {
      case CONVERSIONS:
        return renderConversions()
      case PROPS:
        return renderProps()
      case FUNNELS:
        return renderFunnels()
    }
  }

  function defaultMode() {
    if (enabledModes.length === 0) {
      return null
    }

    const storedMode = storage.getItem(tabKey)
    if (storedMode && enabledModes.includes(storedMode)) {
      return storedMode
    }

    if (enabledModes.includes(CONVERSIONS)) {
      return CONVERSIONS
    }
    if (enabledModes.includes(PROPS)) {
      return PROPS
    }
    return FUNNELS
  }

  function getEnabledModes() {
    let enabledModes = []

    for (const feature of Object.keys(sectionTitles)) {
      const isOptedOut = site[feature + 'OptedOut']
      const isAvailable = site[feature + 'Available'] !== false

      // If the feature is not supported by the site owner's subscription,
      // it only makes sense to display the feature tab to the owner itself
      // as only they can upgrade to make the feature available.
      const callToActionIsMissing = !isAvailable && user.role !== 'owner'

      if (!isOptedOut && !callToActionIsMissing) {
        enabledModes.push(feature)
      }
    }

    return enabledModes
  }

  function isEnabled(mode) {
    return enabledModes.includes(mode)
  }

  function isRealtime() {
    return query.period === 'realtime'
  }

  function sectionTitle() {
    if (mode === CONVERSIONS) {
      return specialTitleWhenGoalFilter(query, sectionTitles[mode])
    } else {
      return sectionTitles[mode]
    }
  }

  function renderImportedQueryUnsupportedWarning() {
    if (mode === CONVERSIONS) {
      return (
        <ImportedQueryUnsupportedWarning
          loading={loading}
          skipImportedReason={skipImportedReason}
        />
      )
    } else if (mode === PROPS) {
      return (
        <ImportedQueryUnsupportedWarning
          loading={loading}
          skipImportedReason={skipImportedReason}
          message="Imported data is unavailable in this view"
        />
      )
    } else {
      return (
        <ImportedQueryUnsupportedWarning
          altCondition={importedDataInView}
          message="Imported data is unavailable in this view"
        />
      )
    }
  }

  if (!mode) {
    return null
  }

  return (
    <div className="items-start justify-between block w-full mt-6 md:flex relative">
      <div className="w-full p-4 bg-white rounded-md shadow-sm dark:bg-gray-900">
        <div className="flex justify-between w-full">
          <div className="flex gap-x-1">
            <h3 className="font-bold dark:text-gray-100">
              {sectionTitle() + (isRealtime() ? ' (last 30min)' : '')}
            </h3>
            {renderImportedQueryUnsupportedWarning()}
          </div>
          <TabWrapper>
            {isEnabled(CONVERSIONS) && (
              <TabButton
                active={mode === CONVERSIONS}
                onClick={setTabFactory(CONVERSIONS)}
              >
                {t('goals')}
              </TabButton>
            )}
            {isEnabled(PROPS) && (
              <TabButton active={mode === PROPS} onClick={setTabFactory(PROPS)}>
                {t('properties')}
              </TabButton>
            )}
            {isEnabled(FUNNELS) &&
              Funnel &&
              (site.funnels.length > 0 && site.funnelsAvailable ? (
                <DropdownTabButton
                  className="md:relative"
                  transitionClassName="md:left-auto md:w-96 md:origin-top-right"
                  active={mode === FUNNELS}
                  options={site.funnels.map(({ name }) => ({
                    label: name,
                    onClick: setFunnelFactory(name),
                    selected: mode === FUNNELS && selectedFunnel === name
                  }))}
                  collectionTitle={t('funnels')}
                  searchable={true}
                >
                  {t('funnels')}
                </DropdownTabButton>
              ) : (
                <TabButton
                  active={mode === FUNNELS}
                  onClick={setTabFactory(FUNNELS)}
                >
                  {t('funnels')}
                </TabButton>
              ))}
          </TabWrapper>
        </div>
        {renderContent()}
      </div>
    </div>
  )
}
