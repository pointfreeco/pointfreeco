import Models

extension Episode {
  public static let all: [Self] = [
    .ep0_introduction,
    .ep1_functions,
    .ep2_sideEffects,
    .ep3_uikitStylingWithFunctions,
    .ep4_algebraicDataTypes,
    .ep5_higherOrderFunctions,
    .ep6_setters,
    .ep7_settersAndKeyPaths,
    .ep8_gettersAndKeyPaths,
    .ep9_algebraicDataTypes_exponents,
    .ep10_aTaleOfTwoFlatMaps,
    .ep11_compositionWithoutOperators,
    .ep12_tagged,
    .ep13_theManyFacesOfMap,
    .ep14_contravariance,
    .ep15_settersErgonomicsAndPerformance,
    .ep16_dependencyInjectionMadeEasy,
    .ep17_stylingWithOverture,
    .ep18_dependencyInjectionMadeComfortable,
    .ep19_algebraicDataTypes_genericsAndRecursion,
    .ep20_nonEmpty,
    .ep21_playgroundDrivenDevelopment,
    .ep22_aTourOfPointFree,
    .ep23_theManyFacesOfZip_pt1,
    .ep24_theManyFacesOfZip_pt2,
    .ep25_theManyFacesOfZip_pt3,
    .ep26_domainSpecificLanguages_pt1,
    .ep27_domainSpecificLanguages_pt2,
    .ep28_anHtmlDsl,
    .ep29_dslsVsTemplatingLanguages,
    .ep30_composableRandomness,
    .ep31_decodableRandomness_pt1,
    .ep32_decodableRandomness_pt2,
    .ep33_protocolWitnesses_pt1,
    .ep34_protocolWitnesses_pt2,
    .ep35_advancedProtocolWitnesses_pt1,
    .ep36_advancedProtocolWitnesses_pt2,
    .ep37_protocolOrientedLibraryDesign_pt1,
    .ep38_protocolOrientedLibraryDesign_pt2,
    .ep39_witnessOrientedLibraryDesign,
    .ep40_asyncFunctionalRefactoring,
    .ep41_aTourOfSnapshotTesting,
    .ep42_theManyFacesOfFlatMap_pt1,
    .ep43_theManyFacesOfFlatMap_pt2,
    .ep44_theManyFacesOfFlatMap_pt3,
    .ep45_theManyFacesOfFlatMap_pt4,
    .ep46_theManyFacesOfFlatMap_pt5,
    .ep47_predictableRandomness_pt1,
    .ep48_predictableRandomness_pt2,
    .ep49_generativeArt_pt1,
    .ep50_generativeArt_pt2,
    .ep51_structs🤝Enums,
    .ep52_enumProperties,
    .ep53_swiftSyntaxEnumProperties,
    .ep54_advancedSwiftSyntaxEnumProperties,
    .ep55_swiftSyntaxCommandLineTool,
    .ep56_whatIsAParser_pt1,
    .ep57_whatIsAParser_pt2,
    .ep58_whatIsAParser_pt3,
    .ep59_composableParsing_map,
    .ep60_composableParsing_flatMap,
    .ep61_composableParsing_zip,
    .ep62_parserCombinators_pt1,
    .ep63_parserCombinators_pt2,
    .ep64_parserCombinators_pt3,
    .ep65_swiftuiAndStateManagement_pt1,
    .ep66_swiftuiAndStateManagement_pt2,
    .ep67_swiftuiAndStateManagement_pt3,
    .ep68_composableStateManagement_reducers,
    .ep69_composableStateManagement_statePullbacks,
    .ep70_composableStateManagement_actionPullbacks,
    .ep71_composableStateManagement_higherOrderReducers,
    .ep72_modularStateManagement_reducers,
    .ep73_modularStateManagement_viewState,
    .ep74_modularStateManagement_viewActions,
    .ep75_modularStateManagement_thePoint,
    .ep76_effectfulStateManagement_synchronousEffects,
    .ep77_effectfulStateManagement_unidirectionalEffects,
    .ep78_effectfulStateManagement_asynchronousEffects,
    .ep79_effectfulStateManagement_thePoint,
    .ep80_theCombineFrameworkAndEffects_pt1,
    .ep81_theCombineFrameworkAndEffects_pt2,
    .ep82_testableStateManagement_reducers,
    .ep83_testableStateManagement_effects,
    .ep84_testableStateManagement_ergonomics,
    .ep85_testableStateManagement_thePoint,
    .ep86_swiftUiSnapshotTesting,
    .ep87_theCaseForCasePaths_pt1,
    .ep88_theCaseForCasePaths_pt2,
    .ep89_theCaseForCasePaths_pt3,
    .ep90_composingArchitectureWithCasePaths,
    .ep91_modularDependencyInjection_pt1,
    .ep92_modularDependencyInjection_pt2,
    .ep93_modularDependencyInjection_pt3,
    .ep94_adaptiveStateManagement_pt1,
    .ep95_adaptiveStateManagement_pt2,
    .ep96_adaptiveStateManagement_pt3,
    .ep97_adaptiveStateManagement_pt4,
    .ep98_ergonomicStateManagement_pt1,
    .ep99_ergonomicStateManagement_pt2,
    .ep100_ATourOfTheComposableArchitecture_pt1,
    .ep101_ATourOfTheComposableArchitecture_pt2,
    .ep102_ATourOfTheComposableArchitecture_pt3,
    .ep103_ATourOfTheComposableArchitecture_pt4,
    .ep104_combineSchedulers_testingTime,
    .ep105_combineSchedulers_controllingTime,
    .ep106_combineSchedulers_erasingTime,
    .ep107_composableSwiftUIBindings_pt1,
    .ep108_composableSwiftUIBindings_pt2,
    .ep109_composableSwiftUIBindings_pt3,
    .ep110_designingDependencies_pt1,
    .ep111_designingDependencies_pt2,
    .ep112_designingDependencies_pt3,
    .ep113_designingDependencies_pt4,
    .ep114_designingDependencies_pt5,
    .ep115_redactions_pt1,
    .ep116_redactions_pt2,
    .ep117_redactions_pt3,
    .ep118_redactions_pt4,
    .ep119_parsersRecap,
    .ep120_parsersRecap,
    .ep121_parsersRecap,
    .ep122_parsersRecap,
    .ep123_fluentlyZippingParsers,
    .ep124_generalizedParsing,
    .ep125_generalizedParsing,
    .ep126_generalizedParsing,
    .ep127_parsingPerformance,
    .ep128_parsingPerformance,
    .ep129_parsingPerformance,
    .ep130_parsingPerformance,
    .ep131_conciseForms,
    .ep132_conciseForms,
    .ep133_conciseForms,
    .ep134_conciseForms,
    .ep135_animations,
    .ep136_animations,
    .ep137_animations,
    .ep138_betterTestDependencies,
    .ep139_betterTestDependencies,
    .ep140_betterTestDependencies,
    .ep141_betterTestDependencies,
    .ep142_tourOfIsowords,
    .ep143_tourOfIsowords,
    .ep144_tourOfIsowords,
    .ep145_tourOfIsowords,
    .ep146_derivedBehavior,
    .ep147_derivedBehavior,
    .ep148_derivedBehavior,
    .ep149_derivedBehavior,
    .ep150_derivedBehavior,
    .ep151_scopePerformance,
    .ep152_casePathPerformance,
    .ep153_asyncRefreshableSwiftUI,
    .ep154_asyncRefreshableTCA,
    .ep155_focusState,
    .ep156_searchable,
    .ep157_searchable,
    .ep158_saferConciserForms,
    .ep159_saferConciserForms,
    .ep160_navigationTabsAndAlerts,
    .ep161_navigationTabsAndAlerts,
    .ep162_navigationSheets,
    .ep163_navigationSheets,
    .ep164_navigationSheets,
    .ep165_navigationLinks,
    .ep166_navigationLinks,
    .ep167_navigationLinks,
    .ep168_navigationThePoint,
    .ep169_uikitNavigation,
    .ep170_uikitNavigation,
    .ep171_modularization,
    .ep172_modularization,
    .ep173_parserBuilders,
    .ep174_parserBuilders,
    .ep175_parserBuilders,
    .ep176_parserErrors,
    .ep177_parserErrors,
    .ep178_parserPrinters,
    .ep179_parserPrinters,
    .ep180_parserPrinters,
    .ep181_parserPrinters,
    .ep182_parserPrinters,
    .ep183_parserPrinters,
    .ep184_parserPrinters,
    .ep185_tourOfParserPrinters,
    .ep186_tourOfParserPrinters,
    .ep187_tourOfParserPrinters,
    .ep188_tourOfParserPrinters,
    .ep189_tourOfParserPrinters,
    .ep190_concurrency,
    .ep191_concurrency,
    .ep192_concurrency,
    .ep193_concurrency,
    .ep194_concurrency,
    .ep195_tcaConcurrency,
    .ep196_tcaConcurrency,
    .ep197_tcaConcurrency,
    .ep198_tcaConcurrency,
    .ep199_tcaConcurrency,
    .ep200_tcaConcurrency,
    .ep201_reducerProtocol,
    .ep202_reducerProtocol,
    .ep203_reducerProtocol,
    .ep204_reducerProtocol,
    .ep205_reducerProtocol,
    .ep206_reducerProtocol,
    .ep207_reducerProtocol,
    .ep208_reducerProtocol,
    .ep209_clocks,
    .ep210_clocks,
    .ep211_navStacks,
    .ep212_navStacks,
    .ep213_navStacks,
    .ep214_modernSwiftUI,
    .ep215_modernSwiftUI,
    .ep216_modernSwiftUI,
    .ep217_modernSwiftUI,
    .ep218_modernSwiftUI,
    .ep219_modernSwiftUI,
    .ep220_modernSwiftUI,
    .ep221_pfLive_dependenciesStacks,
    .ep222_composableNavigation,
    .ep223_composableNavigation,
    .ep224_composableNavigation,
    .ep225_composableNavigation,
    .ep226_composableNavigation,
    .ep227_composableNavigation,
    .ep228_composableNavigation,
    .ep229_composableNavigation,
    .ep230_composableNavigation,
    .ep231_composableStacks,
    .ep232_composableStacks,
    .ep233_composableStacks,
    .ep234_composableStacks,
    .ep235_composableStacks,
    .ep236_composableStacks,
    .ep237_composableStacks,
    .ep238_reliablyTestingAsync,
    .ep239_reliablyTestingAsync,
    .ep240_reliablyTestingAsync,
    .ep241_reliablyTestingAsync,
    .ep242_reliablyTestingAsync,
    .ep243_tourOfTCA,
    .ep244_tourOfTCA,
    .ep245_tourOfTCA,
    .ep246_tourOfTCA,
    .ep247_tourOfTCA,
    .ep248_tourOfTCA,
    .ep249_tourOfTCA,
    .ep250_macroTesting,
    .ep251_macroTesting,
    .ep252_observation,
    .ep253_observation,
    .ep254_observation,
    .ep255_observation,
    .ep256_observationInPractice,
    .ep257_macroCasePaths,
    .ep258_macroCasePaths,
    .ep259_observableArchitecture,
    .ep260_observableArchitecture,
    .ep261_observableArchitecture,
    .ep262_observableArchitecture,
    .ep263_observableArchitecture,
    .ep264_observableArchitecture,
    .ep265_observableArchitecture,
    .ep266_observableArchitecture,
    .ep267_pfLive_observationInPractice,
    .ep268_sharedState,
    .ep269_sharedState,
    .ep270_sharedState,
    .ep271_sharedState,
    .ep272_sharedState,
    .ep273_sharedState,
    .ep274_sharedState,
    .ep275_sharedState,
    .ep276_sharedState,
    .ep277_sharedStateInPractice,
    .ep278_sharedStateInPractice,
    .ep279_sharedStateInPractice,
    .ep280_sharedStateInPractice,
    .ep281_modernUIKit,
    .ep282_modernUIKit,
    .ep283_modernUIKit,
    .ep284_modernUIKit,
    .ep285_modernUIKit,
    .ep286_modernUIKit,
    .ep287_modernUIKit,
    .ep288_modernUIKit,
    .ep289_modernUIKit,
    .ep290_crossPlatform,
    .ep291_crossPlatform,
    .ep292_crossPlatform,
    .ep293_crossPlatform,
    .ep294_crossPlatform,
    .ep295_crossPlatform,
    .ep296_crossPlatform,
    .ep297_equatable,
    .ep298_equatable,
    .ep299_equatable,
    .ep300_equatable,
    .ep301_sqlite,
    .ep302_sqlite,
    .ep303_sqlite,
    .ep304_sqlite,
    .ep305_sharing,
    .ep306_sharing,
    .ep307_sharing,
    .ep308_sharing,
    .ep309_sqliteSharing,
    .ep310_sqliteSharing,
    .ep311_sqliteSharing,
    .ep312_sqliteSharing,
    .ep313_pfLive_SharingGRDB,
    .ep314_sqlBuilding,
    .ep315_sqlBuilding,
    .ep316_sqlBuilding,
    .ep317_sqlBuilding,
    .ep318_sqlBuilding,
    .ep319_sqlBuilding,
    .ep320_sqlBuilding,
    .ep321_sqlBuilding,
    .ep322_sqlBuilding,
    .ep323_modernPersistence,
    .ep324_modernPersistence,
    .ep325_modernPersistence,
    .ep326_modernPersistence,
    .ep327_modernPersistence,
    .ep328_modernPersistence,
    .ep329_pfLive_modernPersistence,
    .ep330_callbacks,
    .ep331_callbacks,
    .ep332_callbacks,
    .ep333_callbacks,
  ]
}
